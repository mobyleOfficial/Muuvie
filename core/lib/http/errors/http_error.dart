enum AppError {
  network('No internet connection'),
  timeout('Request timed out'),
  badRequest('Invalid request'),
  unauthorized('Unauthorized'),
  forbidden('Not allowed'),
  notFound('Resource not found'),
  conflict('Resource already exists'),
  tooManyRequests('Too many requests'),
  server('Server error'),
  unknown('An unknown error occurred');

  final String message;

  const AppError(this.message);
}
