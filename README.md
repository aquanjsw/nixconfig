# Shin Rag's nixconfig

## Secrets

2 types of secret are supported: `by-group` and `by-host`.

`by-group` secrets should be in structure:

```
secrets/
└── by-group
    ├── group-1
    │   ├── secret-1.age
    │   └── secret-2.age
    ├── group-2
    │    ├── secret-1.age
    │    └── secret-2.age
    └── ...
```

then you need to specify which hosts are permitted to access each group in
`secret-registry.nix`.

The `config.age.secrets."by-group/group-1/secret-1".file` assignments are processed automatically so that you can access these secrets like `config.age.secrets."by-group/group-1/secret-1".path` directly.

---

`by-host` secrets should be in structure:

```
secrets/
└── by-host
    ├── any
    │   ├── any-secret-1.age
    │   └── any-secret-2.age
    ├── host-1
    │    ├── secret-1.age
    │    └── secret-2.age
    └── ...
```

Different from `by-group` secrets, `by-host` secrets have host permissions and secret file assignments been processed automatically so that you can access these secrets like `config.age.secrets."by-host/host-1/secret-1".path` directly.

Note that `any` secrets will be transformed to a actual host name like `host-1` to ease access, therefore the secret name of `any` should be unique across all hosts.

_Folder structure are inspired by [blueprint](https://numtide.github.io/blueprint/main/)_
