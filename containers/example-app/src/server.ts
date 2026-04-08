// Placeholder HTTP server for AppRunner. Replace with real application code.
import http from "node:http";

const handleRequest: http.RequestListener = (_req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "ok" }));
};

export const createRequestHandler = (): http.RequestListener => handleRequest;

export const startServer = (
  port = Number(process.env.PORT ?? 8080),
): http.Server => {
  const server = http.createServer(handleRequest);
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
