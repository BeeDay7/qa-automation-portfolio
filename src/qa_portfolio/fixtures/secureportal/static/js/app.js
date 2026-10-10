/* ==========================================================================
   SecurePortal — client behaviour
   ========================================================================== */

(() => {
  "use strict";

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  const api = async (path, options = {}) => {
    const res = await fetch(path, {
      headers: { "Content-Type": "application/json" },
      credentials: "same-origin",
      ...options,
    });
    let body = {};
    try { body = await res.json(); } catch (_) { /* empty is valid */ }
    return { ok: res.ok, status: res.status, body };
  };

  /* ---------- login page ---------------------------------------------- */

  const initLogin = () => {
    const form = $("#login-form");
    if (!form) return;

    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const username = $("#username").value.trim();
      const password = $("#password").value;
      const result = $("#result");

      const { ok, body } = await api("/api/login", {
        method: "POST",
        body: JSON.stringify({ username, password }),
      });

      if (ok) {
        result.textContent = `Authenticated as ${body.role}`;
        result.dataset.auth = "true";
        setTimeout(() => { window.location.href = "/dashboard"; }, 350);
      } else {
        result.textContent = "Authentication failed";
        result.dataset.auth = "false";
      }
    });
  };

  /* ---------- dashboard ----------------------------------------------- */

  const renderPermissionList = (role) => {
    const items = $$(".permission-item");
    const granted = {
      admin: new Set(["session", "admin", "log"]),
      auditor: new Set(["session", "log"]),
      viewer: new Set(["session"]),
    }[role] || new Set();

    items.forEach((item) => {
      const perm = item.dataset.perm;
      const isGranted = granted.has(perm);
      item.dataset.granted = String(isGranted);
      const mark = item.querySelector(".perm-mark");
      if (mark) mark.textContent = isGranted ? "◆" : "◦";
    });
  };

  const renderRecords = (items) => {
    const tbody = $("#records-body");
    if (!tbody) return;

    if (!items || items.length === 0) {
      tbody.innerHTML = `
        <tr class="records-empty">
          <td colspan="4">No records returned.</td>
        </tr>`;
      return;
    }

    tbody.innerHTML = items.map((item) => `
      <tr>
        <td>${item.id}</td>
        <td>${item.title}</td>
        <td>
          <span class="classification-tag" data-level="${item.classification}">
            ${item.classification}
          </span>
        </td>
        <td>${item.updated.replace("T", " ").replace("Z", " UTC")}</td>
      </tr>
    `).join("");
  };

  const renderLog = (events) => {
    const body = $("#log-body");
    if (!body) return;

    if (!events || events.length === 0) {
      body.innerHTML = `<p class="log-empty">No events yet.</p>`;
      return;
    }

    body.innerHTML = events.map((event) => {
      const detail = event.role
        ? `role: ${event.role}`
        : event.reason
          ? `reason: ${event.reason}`
          : "—";
      return `
        <div class="log-row">
          <span class="log-time">${event.timestamp}</span>
          <span class="log-user">${event.username}</span>
          <span class="log-outcome" data-outcome="${event.outcome}">${event.outcome}</span>
          <span class="log-detail">${detail}</span>
        </div>`;
    }).join("");
  };

  const initDashboard = async () => {
    const badge = $("#session-badge");
    if (!badge) return;

    const { body: session } = await api("/api/session");
    if (!session.authenticated) {
      window.location.href = "/";
      return;
    }

    badge.textContent = `${session.username} · ${session.role}`;
    badge.dataset.role = session.role || "";

    const usernameField = $("#inspect-username");
    const nameField = $("#inspect-name");
    const roleBadge = $("#role-badge");
    if (usernameField) usernameField.textContent = session.username || "—";
    if (nameField) nameField.textContent = session.display_name || "—";
    if (roleBadge) {
      roleBadge.textContent = session.role || "—";
      roleBadge.dataset.role = session.role || "";
    }

    renderPermissionList(session.role);

    $("#logout")?.addEventListener("click", async () => {
      await api("/api/logout", { method: "POST" });
      window.location.href = "/";
    });

    $("#load-records")?.addEventListener("click", async () => {
      const tbody = $("#records-body");
      const { ok, status, body } = await api("/api/admin/records");
      if (!ok) {
        if (tbody) {
          tbody.innerHTML = `
            <tr class="records-error">
              <td colspan="4">Forbidden — HTTP ${status}</td>
            </tr>`;
        }
        return;
      }
      renderRecords(body.items);
    });

    const refreshLog = async () => {
      const { ok, body } = await api("/api/auth/log");
      if (!ok) {
        const body_ = $("#log-body");
        if (body_) body_.innerHTML = `<p class="log-empty">Log not available for this role.</p>`;
        return;
      }
      renderLog(body.events);
    };

    $("#refresh-log")?.addEventListener("click", refreshLog);
    await refreshLog();
  };

  /* ---------- boot ---------------------------------------------------- */

  const init = async () => {
    const page = document.body.dataset.page;
    if (page === "login") initLogin();
    if (page === "dashboard") await initDashboard();
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
