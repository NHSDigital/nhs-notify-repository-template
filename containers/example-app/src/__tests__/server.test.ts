import http from "node:http";
import { createRequestHandler, startServer } from "../server";

describe("example-app server", () => {
  describe("createRequestHandler", () => {
    it("returns a request handler function", () => {
      const handler = createRequestHandler();
      expect(typeof handler).toBe("function");
    });

    it("responds with 200 status and JSON body", () => {
      const handler = createRequestHandler();
      const mockRequest = {} as http.IncomingMessage;
      const mockResponse = {
        writeHead: jest.fn(),
        end: jest.fn(),
      } as unknown as http.ServerResponse;

      handler(mockRequest, mockResponse);

      expect(mockResponse.writeHead).toHaveBeenCalledWith(200, {
        "Content-Type": "application/json",
      });
      expect(mockResponse.end).toHaveBeenCalledWith(
        JSON.stringify({ status: "ok" }),
      );
    });
  });

  describe("startServer", () => {
    let server: http.Server;
    const port = 8888;

    afterEach(async () => {
      await new Promise<void>((resolve) => {
        if (server) {
          server.close(() => {
            resolve();
          });
        } else {
          resolve();
        }
      });
    });

    it("starts server on specified port and responds correctly", async () => {
      server = startServer(port);

      await new Promise<void>((resolve, reject) => {
        setTimeout(() => {
          http
            .get(`http://localhost:${port}`, (response) => {
              expect(response.statusCode).toBe(200);
              expect(response.headers["content-type"]).toBe("application/json");

              let body = "";
              response.on("data", (chunk: Buffer) => {
                body += chunk.toString();
              });

              response.on("end", () => {
                expect(JSON.parse(body)).toEqual({ status: "ok" });
                resolve();
              });

              response.on("error", reject);
            })
            .on("error", reject);
        }, 100);
      });
    });
  });
});
