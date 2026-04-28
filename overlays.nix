[
  (self: super: {
    ranger = super.ranger.overrideAttrs ( old: {
      src = super.fetchFromGitHub {
        owner = "ranger";
        repo = "ranger";
        rev = "a8858902ddc7e253e3287dc091775c028ac5665e";
        hash = "sha256-3b9xD8jDiaim0WxHALQpqC/xIa6Lewf30GlUoNsW2qs=";
      };
    });
  })
]