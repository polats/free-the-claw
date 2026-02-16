import type { AnyAgentTool, OpenClawPluginApi } from "../../src/plugins/types.js";
import { createAffineTools } from "./src/tools.js";

export default function register(api: OpenClawPluginApi) {
  const tools = createAffineTools(api);
  for (const tool of tools) {
    api.registerTool(tool as unknown as AnyAgentTool, { optional: true });
  }
}
