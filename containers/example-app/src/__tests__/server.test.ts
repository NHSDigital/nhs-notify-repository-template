import http from 'http';
import { createRequestHandler, startServer } from '../server';

describe('example-app server', () => {
  describe('createRequestHandler', () => {
    it('returns a request handler function', () => {
      const handler = createRequestHandler();
      expect(typeof handler).toBe('function');
    });

    it('responds with 200 status and JSON body', (done) => {
      const handler = createRequestHandler();
      const mockReq = {} as http.IncomingMessage;
      const mockRes = {
        writeHead: jest.fn(),
        end: jest.fn(),
      } as unknown as http.ServerResponse;

      handler(mockReq, mockRes);

      expect(mockRes.writeHead).toHaveBeenCalledWith(200, { 'Content-Type': 'application/json' });
      expect(mockRes.end).toHaveBeenCalledWith(JSON.stringify({ status: 'ok' }));
      done();
    });
  });

  describe('startServer', () => {
    let server: http.Server;
    const port = 8888;

    afterEach((done) => {
      if (server) {
        server.close(done);
      } else {
        done();
      }
    });

    it('starts server on specified port and responds correctly', (done) => {
      server = startServer(port);

      // Wait a bit for server to start
      setTimeout(() => {
        http.get(`http://localhost:${port}`, (res) => {
          expect(res.statusCode).toBe(200);
          expect(res.headers['content-type']).toBe('application/json');

          let body = '';
          res.on('data', (chunk) => {
            body += chunk;
          });

          res.on('end', () => {
            expect(JSON.parse(body)).toEqual({ status: 'ok' });
            done();
          });
        });
      }, 100);
    });
  });
});
