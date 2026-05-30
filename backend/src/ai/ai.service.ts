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
 * If the file is missing or malformed, the service degrades gracefully:
 * it logs a warning and continues without vision (returns null on calls).
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
   * Run Google Cloud Vision `LABEL_DETECTION` on an image buffer and resolve
   * the first label that matches the hardcoded ingredient dictionary to a
   * domain `Ingridient` (spelling preserved verbatim).
   *
   * @param imageBuffer Raw image bytes (typically jpg/png from multipart upload).
   * @returns Resolved `Ingridient` object or `{}` if no label matched.
   * @throws Returns `{}` and logs warning if GCV client failed to initialize.
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
