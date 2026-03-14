let
  age = {
    nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5s2+M3O34c4Uy5bEwri5cGjc3VmgP7b+G0vRxtwSJx";
    personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZWoN6eoYlb8wzoIRONN6syKzxMngiBcCTlVje3rks8";
    work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2KNsLEcAYfipp3phhwmCPIEo6eEBJZ/dZQioWf7KaZ";
  };
in
{
  inherit age;
  ssh = age // {
    phone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHS642RPpdBq/4xCyAIudESLcY9cdBGg667vK1qTJAJl";
  };
}
