import { Type } from "@sinclair/typebox";
import type { OpenClawPluginApi } from "../../../src/plugins/types.js";
import { AffineClient } from "./client.js";

type PluginCfg = {
  affineUrl?: string;
  email?: string;
  password?: string;
};

function getClient(api: OpenClawPluginApi): AffineClient {
  const cfg = (api.pluginConfig ?? {}) as PluginCfg;
  const affineUrl = cfg.affineUrl ?? "http://localhost:3010";
  const email = cfg.email;
  const password = cfg.password;
  if (!email || !password) {
    throw new Error("AFFiNE plugin requires 'email' and 'password' in plugin config");
  }
  return new AffineClient({ affineUrl, email, password });
}

export function createAffineTools(api: OpenClawPluginApi) {
  // Lazily create the client on first tool call so config is resolved at runtime
  let client: AffineClient | null = null;
  const ensureClient = () => {
    if (!client) {
      client = getClient(api);
    }
    return client;
  };

  return [
    {
      name: "affine_list_workspaces",
      label: "AFFiNE: List Workspaces",
      description:
        "List all AFFiNE workspaces the agent has access to. Returns workspace IDs and roles.",
      parameters: Type.Object({}),
      async execute(_id: string, _params: Record<string, unknown>) {
        const c = ensureClient();
        const workspaces = await c.listWorkspaces();
        return {
          content: [{ type: "text" as const, text: JSON.stringify(workspaces, null, 2) }],
        };
      },
    },
    {
      name: "affine_list_docs",
      label: "AFFiNE: List Docs",
      description: "List documents in an AFFiNE workspace with titles and summaries.",
      parameters: Type.Object({
        workspaceId: Type.String({ description: "The workspace ID" }),
      }),
      async execute(_id: string, params: Record<string, unknown>) {
        const c = ensureClient();
        const wsId = params.workspaceId as string;
        if (!wsId) throw new Error("workspaceId is required");
        const docs = await c.listDocs(wsId);
        return {
          content: [{ type: "text" as const, text: JSON.stringify(docs, null, 2) }],
        };
      },
    },
    {
      name: "affine_read_doc",
      label: "AFFiNE: Read Doc",
      description:
        "Read an AFFiNE document's full content as markdown. Returns title and markdown body.",
      parameters: Type.Object({
        workspaceId: Type.String({ description: "The workspace ID" }),
        docId: Type.String({ description: "The document ID" }),
      }),
      async execute(_id: string, params: Record<string, unknown>) {
        const c = ensureClient();
        const wsId = params.workspaceId as string;
        const docId = params.docId as string;
        if (!wsId || !docId) throw new Error("workspaceId and docId are required");
        const result = await c.readDoc(wsId, docId);
        return {
          content: [{ type: "text" as const, text: JSON.stringify(result, null, 2) }],
        };
      },
    },
    {
      name: "affine_update_doc",
      label: "AFFiNE: Update Doc",
      description:
        "Update an AFFiNE document's content from markdown. Uses structural diffing to only change modified blocks.",
      parameters: Type.Object({
        workspaceId: Type.String({ description: "The workspace ID" }),
        docId: Type.String({ description: "The document ID" }),
        markdown: Type.String({ description: "The new markdown content for the document body" }),
      }),
      async execute(_id: string, params: Record<string, unknown>) {
        const c = ensureClient();
        const wsId = params.workspaceId as string;
        const docId = params.docId as string;
        const markdown = params.markdown as string;
        if (!wsId || !docId || markdown == null)
          throw new Error("workspaceId, docId, and markdown are required");
        const result = await c.updateDoc(wsId, docId, markdown);
        return {
          content: [{ type: "text" as const, text: JSON.stringify(result, null, 2) }],
        };
      },
    },
    {
      name: "affine_create_doc",
      label: "AFFiNE: Create Doc",
      description: "Create a new AFFiNE document from markdown. Returns the new document ID.",
      parameters: Type.Object({
        workspaceId: Type.String({ description: "The workspace ID" }),
        title: Type.String({ description: "The document title" }),
        markdown: Type.String({ description: "The markdown content for the document body" }),
      }),
      async execute(_id: string, params: Record<string, unknown>) {
        const c = ensureClient();
        const wsId = params.workspaceId as string;
        const title = params.title as string;
        const markdown = params.markdown as string;
        if (!wsId || !title || markdown == null)
          throw new Error("workspaceId, title, and markdown are required");
        const result = await c.createDoc(wsId, title, markdown);
        return {
          content: [{ type: "text" as const, text: JSON.stringify(result, null, 2) }],
        };
      },
    },
  ];
}
