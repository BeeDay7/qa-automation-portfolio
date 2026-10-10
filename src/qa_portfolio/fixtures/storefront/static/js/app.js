/* ==========================================================================
   Azam Trading Store — storefront client behaviour
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
    try { body = await res.json(); } catch (_) { /* empty body is valid */ }
    return { ok: res.ok, status: res.status, body };
  };

  const escapeHtml = (value) =>
    String(value).replace(/[&<>"']/g, (ch) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;",
      '"': "&quot;", "'": "&#39;",
    }[ch]));

  const formatPrice = (value) => Number(value).toFixed(2);

  /* ---------- state -------------------------------------------------- */

  const state = {
    products: [],
    activeCategory: "All",
    query: "",
    session: { authenticated: false, name: null },
  };

  /* ---------- catalogue rendering ------------------------------------ */

  const productListEl = $("#product-list");
  const productCountEl = $("#product-count");
  const noProductsEl = $("#no-products");

  const renderProduct = (product) => {
    const isOut = product.stock === 0;
    const badge = isOut
      ? `<span class="product-badge">Sold out</span>`
      : product.featured
        ? `<span class="product-badge product-badge--featured">Selected</span>`
        : "";

    const action = isOut
      ? `<button class="btn btn-disabled btn-sm" disabled type="button">Unavailable</button>`
      : `<button class="btn btn-primary btn-sm add" data-id="${product.id}" type="button">Add to basket</button>`;

    return `
      <li
        class="product-card${product.featured ? " is-featured" : ""}"
        data-name="${escapeHtml(product.name)}"
        data-id="${product.id}"
        data-category="${escapeHtml(product.category)}">
        <div class="product-media">
          <a href="/product/${product.id}" aria-label="${escapeHtml(product.name)}">
            <img src="${product.image}" alt="${escapeHtml(product.name)}" loading="lazy" width="400" height="300">
          </a>
          ${badge}
        </div>
        <div class="product-body">
          <p class="product-category">${escapeHtml(product.category)}</p>
          <h3 class="product-name"><a href="/product/${product.id}">${escapeHtml(product.name)}</a></h3>
          <p class="product-description">${escapeHtml(product.description)}</p>
          <dl class="product-specs">
            <div class="product-spec"><dt>Origin</dt><dd>${escapeHtml(product.origin || "—")}</dd></div>
            <div class="product-spec"><dt>Material</dt><dd>${escapeHtml(product.material || "—")}</dd></div>
          </dl>
          <div class="product-footer">
            <span class="product-price"><span class="product-price-currency">$</span>${formatPrice(product.price)}</span>
            ${action}
          </div>
        </div>
      </li>`;
  };

  const visibleProducts = () => {
    const needle = state.query.trim().toLowerCase();
    return state.products.filter((p) => {
      const matchesCategory = state.activeCategory === "All" || p.category === state.activeCategory;
      const matchesQuery = !needle || p.name.toLowerCase().includes(needle);
      return matchesCategory && matchesQuery;
    });
  };

  const renderCatalogue = () => {
    if (!productListEl) return;
    const items = visibleProducts();
    productListEl.innerHTML = items.map(renderProduct).join("");
    if (noProductsEl) noProductsEl.hidden = items.length !== 0;
    if (productCountEl) {
      productCountEl.innerHTML = `
        <span class="section-count-num">${items.length}</span>
        <span class="section-count-label">${items.length === 1 ? "item" : "items"}</span>`;
    }
  };

  /* ---------- session ------------------------------------------------ */

  const sessionBadge = $("#login-state");
  const loginTrigger = $("#open-login");
  const logoutTrigger = $("#logout");

  const refreshSession = async () => {
    const { body } = await api("/api/session");
    state.session = body;
    const authed = Boolean(body.authenticated);
    if (sessionBadge) {
      sessionBadge.textContent = authed ? (body.name || "Signed in") : "Guest";
      sessionBadge.dataset.auth = String(authed);
    }
    if (loginTrigger) loginTrigger.hidden = authed;
    if (logoutTrigger) logoutTrigger.hidden = !authed;
  };

  /* ---------- cart --------------------------------------------------- */

  const cartCountEl = $("#cart-count");
  const cartTotalEl = $("#cart-total");
  const cartItemsEl = $("#cart-items");
  const cartEmptyEl = $("#cart-empty");
  const cartDrawer = $("#cart-drawer");

  const refreshCart = async () => {
    const { body } = await api("/api/cart");
    const items = body.items || [];
    if (cartCountEl) cartCountEl.textContent = String(body.count ?? 0);
    if (cartTotalEl) cartTotalEl.textContent = formatPrice(body.total ?? 0);
    if (cartItemsEl) {
      cartItemsEl.innerHTML = items.map((item) => `
        <li>
          <span>${escapeHtml(item.name)}<span class="qty">× ${item.quantity}</span></span>
          <strong>$${formatPrice(item.price * item.quantity)}</strong>
        </li>`).join("");
    }
    if (cartEmptyEl) cartEmptyEl.hidden = items.length !== 0;
  };

  const openCart = () => {
    if (cartDrawer) {
      cartDrawer.setAttribute("aria-hidden", "false");
      document.body.style.overflow = "hidden";
    }
  };

  const closeCart = () => {
    if (cartDrawer) {
      cartDrawer.setAttribute("aria-hidden", "true");
      document.body.style.overflow = "";
    }
  };

  /* ---------- login dialog ------------------------------------------- */

  const dialog = $("#login-dialog");
  const loginForm = $("#login-form");
  const loginError = $("#login-error");

  const openDialog = () => dialog?.showModal();
  const closeDialog = () => dialog?.close();

  /* ---------- filter chips ------------------------------------------- */

  const initFilters = () => {
    $$(".filter-chip").forEach((chip) => {
      chip.addEventListener("click", () => {
        const category = chip.dataset.category || "All";
        state.activeCategory = category;
        $$(".filter-chip").forEach((c) => {
          const active = c === chip;
          c.classList.toggle("is-active", active);
          c.setAttribute("aria-pressed", String(active));
        });
        renderCatalogue();
      });
    });
  };

  /* ---------- search ------------------------------------------------- */

  const initSearch = () => {
    const input = $("#search");
    if (!input) return;
    let debounce;
    input.addEventListener("input", (e) => {
      clearTimeout(debounce);
      const value = e.target.value;
      debounce = setTimeout(() => {
        state.query = value;
        renderCatalogue();
      }, 150);
    });
  };

  /* ---------- product detail page ------------------------------------ */

  const initProductDetail = () => {
    const form = document.getElementById("product-form");
    if (!form) return;

    const quantity = document.getElementById("quantity");
    const productId = Number(form.dataset.id);

    document.querySelectorAll(".quantity-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        const step = Number(btn.dataset.step);
        const current = Number(quantity.value) || 1;
        const max = Number(quantity.max) || 999;
        const next = Math.min(Math.max(current + step, 1), max);
        quantity.value = String(next);
      });
    });

    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const qty = Math.max(1, Number(quantity.value) || 1);
      const button = document.getElementById("add-to-basket");
      if (button) button.disabled = true;
      try {
        for (let i = 0; i < qty; i += 1) {
          await api("/api/cart/items", {
            method: "POST",
            body: JSON.stringify({ product_id: productId }),
          });
        }
        await refreshCart();
      } finally {
        if (button) button.disabled = false;
      }
    });
  };

  /* ---------- contact form ------------------------------------------- */

  const initContactForm = () => {
    const form = document.getElementById("contact-form");
    if (!form) return;

    const status = document.getElementById("contact-status");
    const submit = document.getElementById("contact-submit");

    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const name = document.getElementById("contact-name").value.trim();
      const email = document.getElementById("contact-email").value.trim();
      const subject = document.getElementById("contact-subject").value.trim();
      const message = document.getElementById("contact-message").value.trim();

      status.textContent = "";
      status.classList.remove("is-error", "is-success");

      if (!name || !email || message.length < 10) {
        status.textContent = "Please fill in your name, email, and a message of at least ten characters.";
        status.classList.add("is-error");
        return;
      }

      if (submit) submit.disabled = true;
      try {
        const { ok, body } = await api("/api/contact", {
          method: "POST",
          body: JSON.stringify({ name, email, subject, message }),
        });
        if (ok) {
          status.textContent = body.message || "Sent.";
          status.classList.add("is-success");
          form.reset();
          const subjectField = document.getElementById("contact-subject");
          if (subjectField) subjectField.value = "General enquiry";
        } else {
          status.textContent = "Something went wrong on our end. Please try again.";
          status.classList.add("is-error");
        }
      } catch (_) {
        status.textContent = "Network error. Please try again.";
        status.classList.add("is-error");
      } finally {
        if (submit) submit.disabled = false;
      }
    });
  };

  /* ---------- account inbox (admin only) ----------------------------- */

  const renderInbox = (messages) => {
    const list = document.getElementById("inbox-list");
    if (!list) return;

    if (!messages || messages.length === 0) {
      list.innerHTML = `<p class="inbox-empty">No messages yet. Write to us through the contact page and they will appear here.</p>`;
      return;
    }

    list.innerHTML = messages.map((msg) => `
      <article class="inbox-message">
        <header class="inbox-message-head">
          <p class="inbox-from">${escapeHtml(msg.name)}</p>
          <p class="inbox-email">${escapeHtml(msg.email)}</p>
          <span class="inbox-time">${escapeHtml(msg.received_at)}</span>
        </header>
        <p class="inbox-subject">${escapeHtml(msg.subject)}</p>
        <p class="inbox-body">${escapeHtml(msg.message)}</p>
      </article>
    `).join("");
  };

  const initInbox = () => {
    const refreshBtn = document.getElementById("inbox-refresh");
    if (!refreshBtn) return;

    refreshBtn.addEventListener("click", async () => {
      const list = document.getElementById("inbox-list");
      const { ok, status, body } = await api("/api/contact/log");
      if (!ok) {
        if (list) {
          list.innerHTML = `<p class="inbox-error">Forbidden — HTTP ${status}</p>`;
        }
        return;
      }
      renderInbox(body.messages);
    });
  };

  /* ---------- global event wiring ------------------------------------ */

  const wireEvents = () => {
    loginTrigger?.addEventListener("click", openDialog);
    $$("[data-close]").forEach((btn) =>
      btn.addEventListener("click", () => closeDialog())
    );

    loginForm?.addEventListener("submit", async (e) => {
      e.preventDefault();
      const email = $("#email").value;
      const password = $("#password").value;
      const { ok } = await api("/api/login", {
        method: "POST",
        body: JSON.stringify({ email, password }),
      });
      if (!ok) {
        if (loginError) {
          loginError.textContent = "Invalid email or password.";
          loginError.hidden = false;
        }
        return;
      }
      if (loginError) loginError.hidden = true;
      closeDialog();
      await Promise.all([refreshSession(), refreshCart()]);
    });

    logoutTrigger?.addEventListener("click", async () => {
      await api("/api/logout", { method: "POST" });
      await Promise.all([refreshSession(), refreshCart()]);
    });

    $("#open-cart")?.addEventListener("click", openCart);
    $("#close-cart")?.addEventListener("click", closeCart);

    cartDrawer?.addEventListener("click", (e) => {
      if (e.target === cartDrawer) closeCart();
    });

    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        if (cartDrawer?.getAttribute("aria-hidden") === "false") closeCart();
      }
    });

    document.addEventListener("click", async (e) => {
      const btn = e.target.closest(".add");
      if (!btn) return;
      e.preventDefault();
      btn.disabled = true;
      try {
        await api("/api/cart/items", {
          method: "POST",
          body: JSON.stringify({ product_id: Number(btn.dataset.id) }),
        });
        await refreshCart();
      } finally {
        btn.disabled = false;
      }
    });

    $("#checkout")?.addEventListener("click", async () => {
      const status = $("#message");
      const { ok, body } = await api("/api/checkout", { method: "POST" });

      if (ok && body.order_id) {
        window.location.href = `/order/${body.order_id}`;
        return;
      }

      if (status) {
        status.textContent = body.message || "Something went wrong.";
        status.classList.toggle("is-error", !ok);
        status.classList.toggle("is-success", false);
      }
    });
  };

  /* ---------- boot --------------------------------------------------- */

  const init = async () => {
    initFilters();
    initSearch();
    initProductDetail();
    initContactForm();
    initInbox();
    wireEvents();

    if (productListEl) {
      const { body } = await api("/api/products");
      state.products = body.items || [];
      renderCatalogue();
    }

    await Promise.all([refreshSession(), refreshCart()]);
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
