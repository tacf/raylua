(function () {
  "use strict";

  const statusEl = document.getElementById("status");
  const consoleEl = document.getElementById("console");
  const runBtn = document.getElementById("run-btn");
  const stopBtn = document.getElementById("stop-btn");
  const exampleSelect = document.getElementById("example-select");
  const canvas = document.getElementById("canvas");
  const canvasPlaceholder = document.getElementById("canvas-placeholder");
  const consoleClearBtn = document.getElementById("console-clear");

  function setStatus(text, kind) {
    statusEl.textContent = text;
    statusEl.className = "status" + (kind ? " " + kind : "");
  }

  function logLine(text) {
    consoleEl.textContent += text + "\n";
    consoleEl.scrollTop = consoleEl.scrollHeight;
  }

  consoleClearBtn.addEventListener("click", () => {
    consoleEl.textContent = "";
  });

  const editor = CodeMirror.fromTextArea(document.getElementById("editor"), {
    mode: "lua",
    theme: "dracula",
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    indentWithTabs: false,
    matchBrackets: true,
  });

  let running = false;
  let moduleReady = false;
  let mod = null;

  function setRunning(isRunning) {
    running = isRunning;
    runBtn.disabled = isRunning || !moduleReady;
    stopBtn.disabled = !isRunning;
    canvasPlaceholder.style.display = isRunning ? "none" : "";
  }

  runBtn.addEventListener("click", () => {
    if (running || !moduleReady) return;
    setRunning(true);
    setStatus("running…", "ok");
    const src = editor.getValue();
    mod
      .ccall("raylua_web_run", null, ["string"], [src], { async: true })
      .catch((err) => {
        logLine("[engine] " + err);
      })
      .finally(() => {
        setRunning(false);
        setStatus("idle");
      });
  });

  stopBtn.addEventListener("click", () => {
    if (!running || !mod) return;
    mod.ccall("raylua_web_request_stop", null, [], []);
    setStatus("stopping…");
  });

  function loadExampleText(path) {
    return fetch("examples/" + path)
      .then((r) => {
        if (!r.ok) throw new Error("HTTP " + r.status);
        return r.text();
      })
      .then((text) => editor.setValue(text));
  }

  fetch("examples/manifest.json")
    .then((r) => r.json())
    .then((list) => {
      exampleSelect.innerHTML = "";
      const byCategory = {};
      for (const item of list) {
        (byCategory[item.category] ||= []).push(item);
      }
      for (const category of Object.keys(byCategory).sort()) {
        const group = document.createElement("optgroup");
        group.label = category;
        for (const item of byCategory[category]) {
          const opt = document.createElement("option");
          opt.value = item.path;
          opt.textContent = item.title;
          group.appendChild(opt);
        }
        exampleSelect.appendChild(group);
      }
      exampleSelect.addEventListener("change", () => {
        loadExampleText(exampleSelect.value).catch((err) =>
          logLine("[examples] failed to load " + exampleSelect.value + ": " + err)
        );
      });
      if (list.length) {
        exampleSelect.value = list[0].path;
        return loadExampleText(list[0].path);
      }
    })
    .catch((err) => {
      logLine("[examples] failed to load manifest: " + err);
    });

  setRunning(false);
  setStatus("booting engine…");

  RayluaModule({
    canvas: canvas,
    print: logLine,
    printErr: logLine,
    setStatus: (text) => {
      if (text) setStatus(text);
    },
    locateFile: (path) => path,
  })
    .then((instance) => {
      mod = instance;
      moduleReady = true;
      setRunning(false);
      setStatus("ready");
    })
    .catch((err) => {
      setStatus("engine failed to load", "error");
      logLine("[engine] failed to initialize: " + err);
    });
})();
