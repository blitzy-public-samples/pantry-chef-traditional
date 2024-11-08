class StatusCodes {
  StatusCodes._();

  //General
  static const int ok = 200;
  static const int created = 201;

  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int notFound = 404;
  static const int tokenExpired = 419;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int serverBeingUpdated = 503;
}
