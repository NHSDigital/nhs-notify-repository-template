import { handler } from '../index';

describe('event-logging Lambda', () => {
  let logSpy: jest.SpyInstance;

  beforeAll(() => {
    logSpy = jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    logSpy.mockClear();
  });

  afterAll(() => {
    logSpy.mockRestore();
  });

  it('logs the input event and returns 200', async () => {
    const event = { foo: 'bar' };
    const result = await handler(event, {} as any, () => undefined);

    expect(logSpy).toHaveBeenCalledWith('Received event:', event);
    expect(result).toEqual({
      statusCode: 200,
      body: 'Event logged',
    });
  });
});
