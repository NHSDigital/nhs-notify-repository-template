// Placeholder HTTP server for AppRunner. Replace with real application code.
import http from 'http';

export const createRequestHandler = () => {
  return (_req: http.IncomingMessage, res: http.ServerResponse) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
  };
};

export const startServer = (port: number = Number(process.env.PORT ?? 8080)) => {
  const server = http.createServer(createRequestHandler());
  server.listen(port, () => {
    console.log(`Placeholder app listening on port ${port}`);
  });
  return server;
};

/* istanbul ignore next */
// Only start server on local/direct run
if (require.main === module) {
  startServer();
}
