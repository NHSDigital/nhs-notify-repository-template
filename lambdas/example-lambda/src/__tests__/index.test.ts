import { handler } from "..";

describe("event-logging Lambda", () => {
  it("logs the input event and returns 200", async () => {
    const event = { foo: "bar" };
    const result = await handler(event);

    expect(result).toEqual({
      statusCode: 200,
      body: "Event logged",
    });
  });
});
