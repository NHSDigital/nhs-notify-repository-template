import { handler } from '../index';

describe('event-logging Lambda', () => {
  it('logs the input event and returns 200', async () => {
    const event = { foo: 'bar' };
    const context = {} as any;
    const callback = jest.fn();
    const result = await handler(event, context, callback);

    expect(result).toEqual({
      statusCode: 200,
      body: 'Event logged',
    });
  });
});
