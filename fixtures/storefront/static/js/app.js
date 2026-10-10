/* DemoMart storefront — client behaviour against the FastAPI fixture. */

const api = async (path, options = {}) => {
  const res = await fetch(path, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  let body = {};
  try { body = await res.json(); } catch (_) { /* ignore */ }
  return { ok: res.ok, status: res.status, body };
};

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

/* ---------- session ------------------------------------------------------- */

async function refreshSession() {
  const { body } = await api("/api/session");
  const authed = Boolean(body.authenticated);
  const badge = $("#login-state");
  badge.textContent = authed ? `Signed in · ${body.name}` : "Signed out";
  badge.dataset.auth = String(authed);
  $("#open-login").hidden = authed;
  $("#logout").hidden = !authed;
}

/* ---------- catalogue ----------------------------------------------------- */

async function refreshProducts(query = "") {
  const url = query ? `/api/products?q=${encodeURIComponent(query)}` : "/api/products";
  const { body } = await api(url);
  renderProducts(body.items || []);
  $("#product-count").textContent = `${body.count ?? 0} products`;
}

function renderProducts(items) {
  const list = $("#product-list");
  list.innerHTML = "";
  for (const p of items) {
    const li = document.createElement("li");
    li.className = "product-card";
    li.dataset.name = p.name;
    li.dataset.id = String(p.id);
    li.innerHTML = `
      <div class="product-media" aria-hidden="true"><span class="product-sku">${p.sku}</span></div>
      <div class="product-body">
        <p class="product-category">${p.category}</p>
        <h3 class="product-name">${p.name}</h3>
        <p class="product-description">${p.description}</p>
        <div class="product-footer">
          <span class="product-price">$${p.price.toFixed(2)}</span>
          ${p.stock > 0
            ? `<button class="btn btn-primary add" data-id="${p.id}">Add to cart</button>`
            : `<button class="btn btn-disabled" disabled>Out of stock</button>`}
        </div>
      </div>`;
    list.appendChild(li);
  }
  $("#no-products").hidden = items.length !== 0;
}

/* ---------- cart ---------------------------------------------------------- */

async function refreshCart() {
  const { body } = await api("/api/cart");
  $("#cart-count").textContent = String(body.count ?? 0);
  $("#cart-total").textContent = (body.total ?? 0).toFixed(2);
  const list = $("#cart-items");
  list.innerHTML = "";
  for (const item of body.items || []) {
    const li = document.createElement("li");
    li.innerHTML = `
      <span>${item.name} <span class="qty">×${item.quantity}</span></span>
      <span>$${(item.price * item.quantity).toFixed(2)}</span>`;
    list.appendChild(li);
  }
  $("#cart-empty").hidden = (body.items || []).length !== 0;
}

/* ---------- event wiring -------------------------------------------------- */

function setStatus(el, text, kind = "") {
  el.textContent = text;
  el.classList.remove("is-error", "is-success");
  if (kind) el.classList.add(kind);
}

document.addEventListener("DOMContentLoaded", () => {
  // Login dialog
  const dialog = $("#login-dialog");
  $("#open-login").addEventListener("click", () => dialog.showModal());
  $$("[data-close]").forEach((b) => b.addEventListener("click", () => dialog.close()));

  $("#login-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const email = $("#email").value;
    const password = $("#password").value;
    const { ok, body } = await api("/api/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
    const errorBox = $("#login-error");
    if (!ok) {
      errorBox.textContent = "Invalid email or password.";
      errorBox.hidden = false;
      return;
    }
    errorBox.hidden = true;
    dialog.close();
    await refreshSession();
    await refreshCart();
  });

  $("#logout").addEventListener("click", async () => {
    await api("/api/logout", { method: "POST" });
    await refreshSession();
  });

  // Cart drawer
  const drawer = $("#cart-drawer");
  $("#open-cart").addEventListener("click", () => drawer.setAttribute("aria-hidden", "false"));
  $("#close-cart").addEventListener("click", () => drawer.setAttribute("aria-hidden", "true"));

  // Add to cart
  $("#product-list").addEventListener("click", async (e) => {
    const btn = e.target.closest(".add");
    if (!btn) return;
    await api("/api/cart/items", {
      method: "POST",
      body: JSON.stringify({ product_id: Number(btn.dataset.id) }),
    });
    await refreshCart();
  });

  // Checkout
  $("#checkout").addEventListener("click", async () => {
    const { ok, body } = await api("/api/checkout", { method: "POST" });
    const status = $("#message");
    setStatus(status, body.message || "", ok ? "is-success" : "is-error");
  });

  // Search
  let debounce;
  $("#search").addEventListener("input", (e) => {
    clearTimeout(debounce);
    debounce = setTimeout(() => refreshProducts(e.target.value), 180);
  });

  // Boot
  (async () => {
    await refreshProducts();
    await refreshCart();
    await refreshSession();
  })();
});
