const request = require("supertest");
const { app, server } = require("../src/index");

afterAll((done) => {
  server.close(done); // closes server after all tests finish
});

describe("App Endpoints", () => {
  it("GET / returns app info", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("message");
    expect(res.body).toHaveProperty("version");
  });

  it("GET /health returns healthy status", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("healthy");
  });

  it("GET /ready returns ready status", async () => {
    const res = await request(app).get("/ready");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("ready");
  });
});