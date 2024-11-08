import { instanceToPlain } from 'class-transformer';

export class EntityRelationalHelper {
  __entity?: string;

  setEntityName() {
    this.__entity = this.constructor.name;
  }

  toJSON() {
    return instanceToPlain(this);
  }
}
