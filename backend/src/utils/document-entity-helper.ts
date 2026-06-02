import { Transform } from 'class-transformer';

/**
 * Shared base class extended by the Mongoose document entities (schemas)
 * across the backend.
 *
 * Its sole responsibility is to expose the document `_id` and apply a
 * `class-transformer` `@Transform` that converts the underlying Mongo
 * `ObjectId` to its string form. The transform runs ONLY during
 * instance-to-plain serialization (`toPlainOnly: true`): when class
 * instances are serialized into plain response objects. It does NOT run
 * on the plain-to-class direction, so plain input is left untouched.
 *
 */
export class EntityDocumentHelper {
  @Transform(
    (value) => {
      // Guard for class-transformer's TransformFnParams shape.
      if ('value' in value) {
        // https://github.com/typestack/class-transformer/issues/879
        return value.obj[value.key].toString();
      }

      // Fallback string when the transform params lack a value.
      return 'unknown value';
    },
    {
      toPlainOnly: true,
    },
  )
  // Document identifier; stringified from ObjectId on to-plain serialization only.
  public _id: string;
}
