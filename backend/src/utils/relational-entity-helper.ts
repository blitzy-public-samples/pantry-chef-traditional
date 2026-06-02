import { instanceToPlain } from 'class-transformer';

/**
 * Base class for relational-style entities. It adds runtime entity-name
 * capture and plain-object serialization, backed by `class-transformer`'s
 * `instanceToPlain`.
 *
 * Subclasses inherit `setEntityName()` to record their concrete class name
 * and `toJSON()` to serialize instances (applying any `class-transformer`
 * decorators). `setEntityName()` is not invoked automatically; callers must
 * call it explicitly to populate `__entity`.
 *
 */
export class EntityRelationalHelper {
  // Optional runtime marker holding the concrete entity class name.
  __entity?: string;

  /**
   * Records the concrete subclass name into `__entity` via
   * `this.constructor.name`, enabling polymorphic / relational instance
   * identification. It is not called automatically; callers must invoke it
   * explicitly to populate `__entity`.
   *
   */
  setEntityName() {
    this.__entity = this.constructor.name;
  }

  /**
   * Serializes this instance to a plain object via `instanceToPlain(this)`,
   * applying any `class-transformer` decorators declared on the entity.
   *
   * @returns the plain-object representation of this instance.
   *
   */
  toJSON() {
    return instanceToPlain(this);
  }
}
