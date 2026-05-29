import { Injectable } from '@nestjs/common';
import { ImageAnnotatorClient } from '@google-cloud/vision';
import { IngridientService } from 'src/ingridient/ingridient.service';

@Injectable()
export class AiService {
  private client: ImageAnnotatorClient;
  private isGoogleVisionEnabled = true;
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

  constructor(private readonly ingirdientService: IngridientService) {
    // SECURITY(SEC-B2): Load GCV credentials from environment variable instead of disk
    // Preserves graceful-degradation: missing/unparseable creds => isGoogleVisionEnabled=false, empty result
    const raw = process.env.GOOGLE_CLOUD_VISION_CREDENTIALS;
    if (!raw) {
      this.isGoogleVisionEnabled = false;
      console.warn(
        'GOOGLE_CLOUD_VISION_CREDENTIALS not set; AI vision disabled',
      );
    } else {
      try {
        const credentials = JSON.parse(raw);
        this.client = new ImageAnnotatorClient({ credentials });
        this.isGoogleVisionEnabled = true;
      } catch {
        this.isGoogleVisionEnabled = false;
        console.warn(
          'GOOGLE_CLOUD_VISION_CREDENTIALS could not be parsed; AI vision disabled',
        );
      }
    }
  }

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
