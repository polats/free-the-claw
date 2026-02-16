/**
 * HTTP client for the AFFiNE REST API.
 * Authenticates via email/password sign-in and caches session cookies.
 * Re-authenticates automatically on 401.
 */
export class AffineClient {
  private baseUrl: string;
  private email: string;
  private password: string;
  private cookies: string | null = null;

  constructor(opts: { affineUrl: string; email: string; password: string }) {
    this.baseUrl = opts.affineUrl.replace(/\/+$/, "");
    this.email = opts.email;
    this.password = opts.password;
  }

  private async signIn(): Promise<void> {
    const res = await fetch(`${this.baseUrl}/api/auth/sign-in`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: this.email, password: this.password }),
      redirect: "manual",
    });

    if (!res.ok && res.status !== 302) {
      throw new Error(`AFFiNE sign-in failed: ${res.status} ${res.statusText}`);
    }

    // Collect Set-Cookie headers
    const setCookies = res.headers.getSetCookie?.() ?? [];
    if (setCookies.length === 0) {
      // Fallback: try raw header
      const raw = res.headers.get("set-cookie");
      if (raw) {
        setCookies.push(...raw.split(/,(?=\s*\w+=)/));
      }
    }

    this.cookies = setCookies.map((c: string) => c.split(";")[0]).join("; ");

    if (!this.cookies) {
      throw new Error("AFFiNE sign-in returned no session cookies");
    }
  }

  private async request(path: string, init: RequestInit = {}): Promise<Response> {
    if (!this.cookies) {
      await this.signIn();
    }

    const doFetch = () =>
      fetch(`${this.baseUrl}${path}`, {
        ...init,
        headers: {
          ...((init.headers as Record<string, string>) ?? {}),
          Cookie: this.cookies!,
        },
      });

    let res = await doFetch();

    // Re-authenticate on 401 (session expired)
    if (res.status === 401) {
      await this.signIn();
      res = await doFetch();
    }

    return res;
  }

  private async json<T>(path: string, init?: RequestInit): Promise<T> {
    const res = await this.request(path, init);
    if (!res.ok) {
      const body = await res.text().catch(() => "");
      throw new Error(`AFFiNE API error ${res.status}: ${path} — ${body}`);
    }
    return (await res.json()) as T;
  }

  async listWorkspaces(): Promise<Array<{ id: string; role: string; createdAt: string }>> {
    return this.json("/api/docs/workspaces");
  }

  async listDocs(wsId: string): Promise<
    Array<{
      id: string;
      title: string;
      summary: string;
      mode: string;
      updatedAt: string;
    }>
  > {
    return this.json(`/api/docs/workspaces/${encodeURIComponent(wsId)}/docs`);
  }

  async readDoc(wsId: string, docId: string): Promise<{ title: string; markdown: string }> {
    return this.json(
      `/api/docs/workspaces/${encodeURIComponent(wsId)}/docs/${encodeURIComponent(docId)}/markdown`,
    );
  }

  async updateDoc(wsId: string, docId: string, markdown: string): Promise<{ success: boolean }> {
    return this.json(
      `/api/docs/workspaces/${encodeURIComponent(wsId)}/docs/${encodeURIComponent(docId)}/markdown`,
      {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ markdown }),
      },
    );
  }

  async createDoc(wsId: string, title: string, markdown: string): Promise<{ docId: string }> {
    return this.json(`/api/docs/workspaces/${encodeURIComponent(wsId)}/docs`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, markdown }),
    });
  }
}
