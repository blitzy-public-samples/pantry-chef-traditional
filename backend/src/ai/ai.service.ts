import { Injectable } from '@nestjs/common';
import { ImageAnnotatorClient } from '@google-cloud/vision';
import * as path from 'path';
import { existsSync } from 'fs';
// NOTE: 'IngridientService' spelling is preserved verbatim across the backend
// codebase. Do not rename.
import { IngridientService } from 'src/ingridient/ingridient.service';

/**
 * Service performing Google Cloud Vision label detection and resolving
 * detected labels to a domain `Ingridient` (spelling preserved verbatim).
 *
 * Credentials are loaded from `backend/src/config/ai.json` (see README).
 * If the file is missing, the service degrades gracefully: it logs an error
 * via console.error, sets `isGoogleVisionEnabled = false`, and returns `{}`
 * (an empty object — not null) from `detectIngredientsFromBuffer` on every call.
 */
@Injectable()
export class AiService {
  private client: ImageAnnotatorClient;
  private isGoogleVisionEnabled = true;
  // TODO(prod): Hardcoded ingredient dictionary (~36 terms).
  // Replace with database-backed lookup before production.
  private ingredientDictionary: string[] = [
    'tomato',
    'onion',
    'garlic',
    'chicken',
    'beef',
    'cheese',
    'milk',
    'egg',
    'fish',
    'rice',
    'bread',
    'butter',
    'cucumber',
    'lettuce',
    'carrot',
    'spinach',
    'mushroom',
    'pepper',
    'salt',
    'oil',
    'black pepper',
    'cinnamon',
    'apple',
    'banana',
    'chicken breast',
    'tofu',
    'flour',
    'tomato sauce',
    'mozzarella cheese',
    'basil',
    'romaine lettuce',
    'parmesan cheese',
    'croutons',
    'caesar dressing',
    'feta cheese',
    'minced beef',
    // Add more ingredients as needed
  ];

  /**
   * @param ingirdientService Resolves detected labels to Ingridient records
   *   via `findManyWithPagination`. Property name typo preserved verbatim.
   */
  // NOTE: Property name 'ingirdientService' is an additional preserved typo
  // (distinct from 'Ingridient'). Do not rename.
  constructor(private readonly ingirdientService: IngridientService) {
    const keyPath = path.join(__dirname, '../config/ai.json');
    if (!existsSync(keyPath)) {
      console.error(`Key file not found at path: ${keyPath}`);
      this.isGoogleVisionEnabled = false;
    }

    this.client = new ImageAnnotatorClient({
      keyFilename: keyPath,
    });
  }

  /**
   * Run Google Cloud Vision `LABEL_DETECTION` on an image buffer and resolve a
   * matching dictionary label to a domain `Ingridient` (spelling preserved
   * verbatim).
   *
   * Behavior below documents the actual implementation, not intended behavior:
   * - Returns `{}` when Google Cloud Vision is disabled (`ai.json` missing) or
   *   when the Vision response contains no labels.
   * - Otherwise it scans ALL returned labels without breaking, so the LAST
   *   matching dictionary term wins (not the first).
   * - The matched term (or `null` when nothing matched) is passed as
   *   `filterOptions` to `IngridientService.findManyWithPagination`. When the
   *   filter is `null` the lookup is unfiltered and returns the first
   *   non-deleted Ingridient — see the FIXME at the lookup call below.
   * - Maps the resolved record to `{ id, name, category, quantity, unit,
   *   confidence }`, or returns `{}` when the lookup yields no record.
   *
   * @param imageBuffer Raw image bytes (typically jpg/png from multipart upload).
   * @returns A plain object: the resolved `Ingridient` fields, or `{}` when
   *   Vision is disabled, returns no labels, or the lookup finds no record.
   *   This method does not throw when the client is disabled — it returns `{}`.
   */
  async detectIngredientsFromBuffer(imageBuffer: Buffer): Promise<any> {
    if (!this.isGoogleVisionEnabled) {
      console.error('Google cloud vision disabled');
      return {};
    }

    const request = {
      image: {
        content: imageBuffer,
      },
      features: [
        {
          type: 'LABEL_DETECTION',
          maxResults: 10,
        },
      ],
    };

    const [response] = await this.client.annotateImage(request);
    const labels = response.labelAnnotations;

    if (!labels) {
      return {};
    }

    // Iterate through labels and find the first match in the dictionary
    // FIXME: loop does not break, so the LAST matching dictionary term wins
    // (despite the legacy "first match" intent). Document only; do not fix.
    let recognizedIngridient: string = null;
    for (const label of labels) {
      const labelDescription = label.description.toLowerCase();

      // Check for exact match
      if (this.ingredientDictionary.includes(labelDescription?.toLowerCase())) {
        recognizedIngridient = labelDescription;
      }

      // Check if any ingredient is included in the label
      for (const ingredient of this.ingredientDictionary) {
        if (labelDescription.includes(ingredient.toLowerCase())) {
          recognizedIngridient = ingredient;
        }
      }
    }

    // FIXME: when no label matched, recognizedIngridient is null and this
    // lookup is unfiltered — it returns the first non-deleted Ingridient, not
    // {}. Document only; do not fix.
    const ingridients: any =
      await this.ingirdientService.findManyWithPagination({
        filterOptions: recognizedIngridient,
        paginationOptions: {
          page: 1,
          limit: 1,
        },
      });
    const [ingridient] = ingridients ?? [];
    const result = ingridient
      ? {
          id: ingridient.id,
          name: ingridient.name,
          category: ingridient.category,
          quantity: ingridient.quantity,
          unit: ingridient.unit,
          confidence: ingridient.confidence,
        }
      : {};

    return result;
  }
}
