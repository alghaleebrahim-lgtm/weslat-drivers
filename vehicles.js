/* أنواع المركبات ورسوماتها — مشتركة بين الفورم ولوحة الأدمن */
(function () {
  const W = (x, r = 4.2) => `<circle cx="${x}" cy="25" r="${r}" class="w"/>`;
  const SHAPES = {
    medium: '<rect x="5" y="6" width="34" height="17" rx="1.5" class="b"/><path d="M42 25V11h9l7 7v7" class="b"/><path d="M44.5 13.5h5.5l4.5 4.5h-10z" class="g"/><path d="M5 25h53" class="b"/>' + W(14) + W(50),
    pickup: '<path d="M5 25v-9h23V9h13l7 7h8a3 3 0 0 1 3 3v6" class="b"/><path d="M31 11.5h8.5l4.5 4.5H31z" class="g"/><path d="M5 16h23" class="b"/>' + W(16) + W(48),
    box: '<path d="M5 25v-9h23V9h13l7 7h8a3 3 0 0 1 3 3v6" class="b"/><path d="M31 11.5h8.5l4.5 4.5H31z" class="g"/><path d="M5 16h23M8 16V9h17v7" class="b"/>' + W(16) + W(48),
    van: '<path d="M5 25V11.5A3.5 3.5 0 0 1 8.5 8h33.5l10 8.5h4.5a3 3 0 0 1 3 3V25" class="b"/><path d="M43 12l5.5 4.5H43z" class="g"/>' + W(16) + W(48),
    large: '<rect x="3" y="4" width="40" height="19" rx="1.5" class="b"/><path d="M45 25V9h8l7 8v8" class="b"/><path d="M47.5 11.5h4.5l5 5.5h-9.5z" class="g"/><path d="M3 25h57" class="b"/>' + W(10) + W(20) + W(53),
    trailer: '<path d="M2 21h40" class="b"/><rect x="2" y="9" width="40" height="12" rx="1" class="b"/><path d="M44 25V10h8l8 8v7" class="b"/><path d="M46.5 12.5h4.5l5.5 5.5h-10z" class="g"/><path d="M40 25h4" class="b"/>' + W(8) + W(17) + W(32) + W(54),
    reefer: '<rect x="5" y="6" width="34" height="17" rx="1.5" class="b"/><path d="M42 25V11h9l7 7v7" class="b"/><path d="M44.5 13.5h5.5l4.5 4.5h-10z" class="g"/><path d="M5 25h53" class="b"/><path d="M22 9.5v10M17.7 12l8.6 5M17.7 17l8.6-5" class="b" style="stroke-width:1.6"/>' + W(14) + W(50),
    moto: '<path d="M14 25l12-11h12l12 11M26 14l-4-6h-4M38 14l6-4" class="b"/><path d="M27 14h10l-3 6h-5z" class="g"/>' + W(14, 6) + W(50, 6),
    other: '<rect x="16" y="5" width="32" height="22" rx="5" class="b"/><path d="M32 11v10M27 16h10" class="b"/>',
  };
  const VEHICLES = [
    { v: "دفار متوسط مقفول", t: "دفار متوسط", s: "مقفول · 3–7 طن", icon: "medium" },
    { v: "بورتر", t: "بورتر", s: "1–1.5 طن", icon: "pickup" },
    { v: "بوكس", t: "بوكس", s: "بيك أب", icon: "box" },
    { v: "حافلة مقفولة (هايس)", t: "حافلة مقفولة", s: "هايس", icon: "van" },
    { v: "دفار كبير", t: "دفار كبير", s: "10 طن وأكثر", icon: "large" },
    { v: "تريلا", t: "تريلا", s: "شاحنة بمقطورة", icon: "trailer" },
    { v: "ثلاجة", t: "ثلاجة", s: "مبرّدة", icon: "reefer" },
    { v: "موتر", t: "موتر", s: "طرود صغيرة", icon: "moto" },
    { v: "أخرى", t: "أخرى", s: "نوع آخر", icon: "other" },
  ];
  // أسماء قديمة سُجّلت قبل تحديث القائمة
  const LEGACY = {
    "حافلة (هايس)": "van", "بيك أب": "pickup", "شاحنة متوسطة (دينا – إيسوزو)": "medium",
    "شاحنة كبيرة (10 أطنان)": "large", "شاحنة بمقطورة": "trailer",
  };
  window.VEHICLES = VEHICLES;
  window.vehicleIcon = v => SHAPES[(VEHICLES.find(x => x.v === v) || {}).icon || LEGACY[v] || "other"];
  window.vehicleCard = (name, x, required) =>
    `<label class="vcard"><input type="radio" name="${name}" value="${x.v}"${required ? " required" : ""}><span class="vbox"><svg viewBox="0 0 64 32" aria-hidden="true">${SHAPES[x.icon]}</svg><b>${x.t}</b><small>${x.s}</small></span></label>`;
  window.CITIES = ["الخرطوم","أم درمان","بحري","بورتسودان","عطبرة","الدامر","شندي","كسلا","حلفا الجديدة","القضارف","ود مدني","سنار","كوستي","ربك","دنقلا","مروي"];
  window.BRANCHES = ["أم درمان","بورتسودان","عطبرة","كسلا","ود مدني"];
})();
