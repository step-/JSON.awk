<a name="0"></a>

<a name="js_dot_path"></a>
## Translating JSON into javascript with js-dot-path.awk

Taking inspiration from [gron](https://github.com/tomnomnom/gron), JSON.awk
can be used to transform JSON into javascript using the callback library file
`js-dot-path.awk`. It will output javascript identical to gron's own, bar
syntax coloring.

This library is not a full replacement for gron, which can can do more things.
Notably, gron can "ungron" javascript into JSON, and can translate a "JSON
stream", which is a sequence of multiple JSON texts in a single file.

### Usage

```sh
awk -f lib/js-dot-path.awk -f JSON.awk -v STREAM=0 [JS_CONTAINER] FILE.json...

JS_CONTAINER: -v _JS_VAR="json" [-v _JS_VAR_VAR="file"]
```

`_JS_VAR` is the name of the javascript root container variable. Default: `json`.

`_JS_VAR_VAR` is the name of an array rooted under `json`. Default: `file`.

Each element of `file` corresponds to an input file. Set `_JS_VAR_VAR="null"`
to omit `file` and root all javascript directly under `json`.  If you are
passing JSON.awk multiple files, you almost always will want to leave
`_JS_VAR_VAR` unset or set it to something different than `"null"`.

### Examples

```
# echo '[1,{},2]' | awk -f lib/js-dot-path.awk -f JSON.awk -v _JS_VAR_VAR="null" -v STREAM=0 -
json = [];
json[0] = 1;
json[1] = {};
json[2] = 2;
```

```
# echo '[1,{},2]' | awk -f lib/js-dot-path.awk -f JSON.awk -v STREAM=0 -
json = {};
json.file = [];
json.file[0] = [];
json.file[0][0] = 1;
json.file[0][1] = {};
json.file[0][2] = 2;
```

```
# echo '[1,{},2]' | awk -f lib/js-dot-path.awk -f JSON.awk -v STREAM=0 lib/test-js-dot-path/testdata/dl-jsontest.json -
json = {};
json.file = [];
json.file[0] = {};
json.file[0]["X-Cloud-Trace-Context"] = "f9ce477415da1f547f1dc3f186e433df/17989231600162709915";
json.file[0].Accept = "*/*";
json.file[0]["User-Agent"] = "curl/7.64.0";
json.file[0].Host = "headers.jsontest.com";
json.file[1] = [];
json.file[1][0] = 1;
json.file[1][1] = {};
json.file[1][2] = 2;
```

[top](#0)

