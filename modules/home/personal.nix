{ pkgs, ... }:
{
  home.packages = [
    pkgs.iina
  ];

  home.file.".pi/agent/models.json".text = builtins.toJSON {
    providers.ollama = {
      baseUrl = "http://localhost:11434/v1";
      api = "openai-completions";
      apiKey = "ollama";
      compat = {
        supportsDeveloperRole = false;
        supportsReasoningEffort = false;
      };
      models = [
        {
          id = "gemma4:31b";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 256000;
        }
        {
          id = "qwen3.6";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 256000;
        }
      ];
    };
  };
}
