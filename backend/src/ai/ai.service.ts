import { Injectable } from '@nestjs/common';
import { ImageAnnotatorClient } from '@google-cloud/vision';
import * as path from 'path';
import { existsSync } from 'fs';
import { IngridientService } from 'src/ingridient/ingridient.service';

/**
 * AI-assisted image-to-ingredient recognition service.
 *
 * Performs ingredient recognition from raw image bytes using Google Cloud
 * Vision `LABEL_DETECTION`. Recognized labels are matched against an internal
 * `ingredientDictionary` (~36 entries), and the matched label is resolved to a
 * persisted ingredient record through the injected `IngridientService`.
 *
 * Holds the `ImageAnnotatorClient`, the `isGoogleVisionEnabled` flag, and the
 * internal `ingredientDictionary`.
 * Source: backend/src/ai/ai.service.ts:L9-L49
 */
@Injectable()
export class AiService {
  // Google Cloud Vision client; constructed in the constructor below.
  private client: ImageAnnotatorClient;
  // Feature flag; set false when the Vision service-account key is missing.
  private isGoogleVisionEnabled = true;
  // Internal label-to-ingredient lookup list matched against Vision labels.
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

  // Injects IngridientService (sic). Used by detectIngredientsFromBuffer to
  // resolve a recognized label to a persisted ingredient record.
  constructor(private readonly ingirdientService: IngridientService) {
    // Resolve the Google Vision service-account key path; at runtime this
    // points to src/config/ai.json. Source: backend/src/ai/ai.service.ts:L52
    const keyPath = path.join(__dirname, '../config/ai.json');
    // Graceful-degradation fallback: when the key file is absent, log an error
    // and disable Vision by setting isGoogleVisionEnabled = false.
    // Source: backend/src/ai/ai.service.ts:L52-L56
    if (!existsSync(keyPath)) {
      console.error(`Key file not found at path: ${keyPath}`);
      this.isGoogleVisionEnabled = false;
    }

    // Construct the ImageAnnotatorClient using keyFilename: keyPath.
    this.client = new ImageAnnotatorClient({
      keyFilename: keyPath,
    });
  }

  /**
   * Detects an ingredient from a raw image buffer via Google Vision label
   * detection.
   *
   * The image is sent to Google Cloud Vision `LABEL_DETECTION`; returned labels
   * are matched against `ingredientDictionary`, and the first recognized label
   * is resolved to a stored ingredient through `ingirdientService`.
   *
   * Implements graceful degradation: when `isGoogleVisionEnabled` is false
   * (missing `ai.json`) the method short-circuits to `{}` so the endpoint still
   * responds 2xx rather than throwing.
   * Source: backend/src/ai/ai.service.ts:L64-L67
   *
   * @param imageBuffer the raw image bytes forwarded from the controller upload
   * @returns a promise resolving to the matched ingredient object
   *   `{ id, name, category, quantity, unit, confidence }`, or an empty object
   *   `{}` when Vision is disabled, returns no labels, or no dictionary match
   *   resolves to a stored ingredient.
   *   Source: backend/src/ai/ai.service.ts:L114-L126
   */
  async detectIngredientsFromBuffer(imageBuffer: Buffer): Promise<any> {
    // Graceful degradation: short-circuit to {} when Vision is disabled.
    if (!this.isGoogleVisionEnabled) {
      console.error('Google cloud vision disabled');
      return {};
    }

    // Build a Vision LABEL_DETECTION request capped at maxResults: 10 labels.
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

    // Send the request to Vision; if it returns no labels, degrade to {}.
    const [response] = await this.client.annotateImage(request);
    const labels = response.labelAnnotations;

    if (!labels) {
      return {};
    }

    // Iterate through labels and find the first match in the dictionary
    // recognizedIngridient (sic) holds the matched dictionary entry, if any.
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

    // Resolve the recognized label to a stored ingredient via
    // ingirdientService.findManyWithPagination (page 1, limit 1); the first of
    // ingridients (sic) becomes ingridient below.
    // Source: backend/src/ingridient/ingridient.service.ts:L40-L54
    const ingridients: any =
      await this.ingirdientService.findManyWithPagination({
        filterOptions: recognizedIngridient,
        paginationOptions: {
          page: 1,
          limit: 1,
        },
      });
    const [ingridient] = ingridients ?? [];
    // Shape the matched ingridient into the response object, or {} when no
    // ingredient matched. Source: backend/src/ai/ai.service.ts:L115-L126
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
