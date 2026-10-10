const api = async (path, options = {}) => {
  const res = await fetch(path, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  let body = {};
  try { body = await res.json(); } catch (_) {}
  return { ok: res.ok, status: res.status, body };
};

const $ = (s) => document.querySelector(s);

/* ---------- login page ---------------------------------------------------- */

if (document.body.dataset.page === "login") {
  $("#login-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const { ok, body } = await api("/api/login", {
      method: "POST",
      body: JSON.stringify({
        username: $("#username").value,
        password: $("#password").value,
      }),
    });
    const result = $("#result");
    if (ok) {
      result.textContent = `Authenticated as ${body.role}`;
      result.dataset.auth = "true";
      setTimeout(() => { window.location.href = "/dashboard"; }, 400);
    } else {
      result.textContent = "Authentication failed";
      result.dataset.auth = "false";
    }
  });
}

/* ---------- dashboard ----------------------------------------------------- */

if (document.body.dataset.page === "dashboard") {
  (async () => {
    const { body } = await api("/api/session");
    $("#session-badge").textContent = body.authenticated
      ? `${body.username} · ${body.role}`
      : "anonymous";
    if (!body.authenticated) window.location.href = "/";
  })();

  $("#logout").addEventListener("click", async () => {
    await api("/api/logout", { method: "POST" });
    window.location.href = "/";
  });

  $("#load-records").addEventListener("click", async () => {
    const { ok, status, body } = await api("/api/admin/records");
    const list = $("#records");
    list.innerHTML = "";
    if (!ok) {
      list.innerHTML = `<li style="color:var(--danger)">Forbidden (HTTP ${status})</li>`;
      return;
    }
    for (const r of body.items || []) {
      const li = document.createElement("li");
      li.innerHTML = `<span>${r.title}</span><code>${r.classification}</code>`;
      list.appendChild(li);
    }
  });
}
