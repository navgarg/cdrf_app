class DomainRecommendation {
  final String category;
  final String title;
  final String description;
  final List<String> actionPoints;

  const DomainRecommendation({
    required this.category,
    required this.title,
    required this.description,
    required this.actionPoints,
  });
}

class DomainRecommendationService {
  const DomainRecommendationService();

  List<DomainRecommendation> getRecommendations(String? businessDomain) {
    switch ((businessDomain ?? '').trim().toLowerCase()) {
      case 'beauty parlor':
        return _beautyParlorRecommendations;
      case 'tiffin services':
        return _tiffinRecommendations;
      case 'tailor shop':
        return _tailorRecommendations;
      case 'grocery seller':
        return _groceryRecommendations;
      case 'convenience store':
        return _convenienceRecommendations;
      default:
        return _defaultRecommendations;
    }
  }

  static const List<DomainRecommendation> _beautyParlorRecommendations = [
    DomainRecommendation(
      category: 'Product',
      title: 'Design clear service packages',
      description:
          'Your product is the full salon experience, not only the haircut or facial. Structure services so customers understand what is basic, premium, and add-on.',
      actionPoints: [
        'Keep 3 levels for key services: basic, premium, and bridal or advanced package.',
        'Add quick upsells such as head massage, cleanup, hair spa, nail add-ons, or eyebrow combo.',
        'Record customer preferences like skin type, preferred stylist, color shade, and visit frequency.',
        'Review which services take less material but bring better revenue, then feature them more visibly.',
      ],
    ),
    DomainRecommendation(
      category: 'Price',
      title: 'Use cost plus margin pricing for every service',
      description:
          'For services, pricing should include material cost, staff time, electricity, rent, and your target profit margin. Service businesses can usually keep a higher margin than product sellers because customer value is tied to skill and trust.',
      actionPoints: [
        'Calculate price as consumable cost + labor cost + overhead share + desired margin.',
        'Ask the owner to enter expected price for each service, then compare it against calculated minimum profitable price.',
        'Keep a higher margin on skilled services such as bridal makeup, facials, coloring, or styling; keep moderate margins on basic services with heavy local competition.',
        'Charge separately for premium products, extra-long hair, urgent bookings, home visits, or festival dates.',
      ],
    ),
    DomainRecommendation(
      category: 'Place',
      title: 'Target the right local catchment area',
      description:
          'A beauty parlor usually grows best from nearby repeat customers, not from very wide delivery-style reach. The main target area should be where repeat visits are easy.',
      actionPoints: [
        'Focus first on homes, apartments, colleges, offices, and wedding clusters within 2 to 5 km.',
        'Offer home service only in selected high-value zones where travel time still keeps margins healthy.',
        'Track where your top repeat clients come from and promote most in those neighborhoods.',
        'Run neighborhood-specific offers before weddings, festivals, school functions, and party seasons.',
      ],
    ),
    DomainRecommendation(
      category: 'Promotion',
      title: 'Promote trust, transformation, and repeat visits',
      description:
          'Beauty businesses grow through visual proof and word of mouth. Promotion should show results, hygiene, and convenience rather than only discounts.',
      actionPoints: [
        'Post before-and-after work, bridal looks, nail work, hair transformations, and customer testimonials on Instagram and WhatsApp Status.',
        'Use referral offers like bring a friend, pre-bridal package booking, or birthday month discount.',
        'Distribute posters and simple flyers in apartments, hostels, gyms, and boutique stores nearby.',
        'Message past clients for rebooking when haircut, cleanup, threading, or color cycles are due.',
      ],
    ),
    DomainRecommendation(
      category: 'Production',
      title: 'Improve capacity, timing, and staff utilization',
      description:
          'Production in a salon means how many quality appointments you can complete in a day without delays, waste, or rushed service.',
      actionPoints: [
        'Track standard service time for haircut, facial, color, waxing, and bridal sessions.',
        'Keep appointment buffers so one delay does not affect the entire day.',
        'Maintain a daily consumables sheet for cream, color, wax, and disposable items.',
        'Reserve premium slots for high-value services and quieter slots for lower-ticket work.',
      ],
    ),
    DomainRecommendation(
      category: '6Cs',
      title: 'Run the parlor with a customer and competition lens',
      description:
          'Use the 6Cs as a management check: customer, cost, convenience, communication, consistency, and competition.',
      actionPoints: [
        'Customer: segment students, working women, bridal clients, and regular maintenance clients.',
        'Cost: watch material use per service so discounts do not quietly remove profit.',
        'Convenience: enable easy booking, digital payments, and reminder calls.',
        'Communication, consistency, competition: keep polite follow-up, standardized hygiene, and a clear difference from nearby parlors.',
      ],
    ),
  ];

  static const List<DomainRecommendation> _tiffinRecommendations = [
    DomainRecommendation(
      category: 'Product',
      title: 'Build meal plans around customer need',
      description:
          'The product is not just food quantity; it is taste consistency, health balance, reliability, and flexibility for different customer groups.',
      actionPoints: [
        'Offer clear variants such as regular meal, mini meal, diet meal, office lunch, and weekly subscription.',
        'Keep menu rotation by weekday so customers know what to expect and raw material planning becomes easier.',
        'Add optional extras such as sweet dish, salad, curd, breakfast, or evening snack.',
        'Collect feedback on spice level, oil level, portion size, and delivery timing every week.',
      ],
    ),
    DomainRecommendation(
      category: 'Price',
      title: 'Price subscription and one-time orders differently',
      description:
          'Tiffin pricing should reflect ingredient cost, fuel, labor, packaging, and delivery. Margins are usually moderate because food has recurring purchase potential but waste can quickly reduce profit.',
      actionPoints: [
        'Calculate base cost per meal using ingredients + packaging + labor + delivery + kitchen overhead.',
        'Ask the owner to enter desired selling price for each meal plan, then highlight whether the price covers the real meal cost.',
        'Keep lower per-meal pricing for monthly subscribers because volume is more stable.',
        'Charge extra for one-time orders, longer distance delivery, premium ingredients, or custom diets.',
      ],
    ),
    DomainRecommendation(
      category: 'Place',
      title: 'Serve zones that can be delivered on time',
      description:
          'Place for tiffin means the delivery zone, route quality, and customer density. Growth should come from compact areas where multiple deliveries happen together.',
      actionPoints: [
        'Target office clusters, PGs, hostels, working bachelor housing, hospitals, and coaching areas first.',
        'Group customers by route and delivery window so fuel and delay stay under control.',
        'Do not expand into far areas unless the route already has enough order density.',
        'Build separate plans for lunch-heavy zones and dinner-heavy residential zones.',
      ],
    ),
    DomainRecommendation(
      category: 'Promotion',
      title: 'Advertise reliability and home-style quality',
      description:
          'Food buyers respond to trust, hygiene, and routine convenience more than flashy branding. Promotion should feel local, personal, and dependable.',
      actionPoints: [
        'Promote weekly menu cards on WhatsApp, local Telegram groups, apartment groups, and office communities.',
        'Distribute posters near PGs, hostels, tuition centers, clinics, and office buildings.',
        'Offer a 2-day trial plan or first week discount to convert hesitant customers.',
        'Collect customer reviews around taste, punctuality, and hygiene, then reuse those reviews in social posts.',
      ],
    ),
    DomainRecommendation(
      category: 'Production',
      title: 'Control wastage and kitchen flow tightly',
      description:
          'Production in tiffin service is the kitchen and dispatch system. The best improvement usually comes from planning, prep, and route discipline.',
      actionPoints: [
        'Fix procurement quantities using subscriber count and a small buffer for one-time orders.',
        'Prepare masala, chopping, dough, and packaging material in batches before peak hours.',
        'Measure cooked quantity versus delivered quantity every day to spot overproduction.',
        'Use simple dispatch checklists so no tiffin misses item count, address, or time slot.',
      ],
    ),
    DomainRecommendation(
      category: '6Cs',
      title: 'Use the 6Cs to improve retention',
      description:
          'For tiffin businesses, the 6Cs help keep repeat customers loyal and operations healthy.',
      actionPoints: [
        'Customer: separate students, office staff, patients, and family subscribers because their meal needs differ.',
        'Cost and convenience: watch food inflation closely and offer easy pause or resume options for subscribers.',
        'Communication: confirm menu, holiday changes, and delay alerts early.',
        'Consistency and competition: keep taste stable and benchmark against nearby mess and cloud kitchen pricing.',
      ],
    ),
  ];

  static const List<DomainRecommendation> _tailorRecommendations = [
    DomainRecommendation(
      category: 'Product',
      title: 'Package tailoring as fit, design, and reliability',
      description:
          'A tailor shop sells fitting confidence and timely delivery. Product design should make service quality easy to understand.',
      actionPoints: [
        'List services separately: blouse stitching, alterations, fall pico, kids wear, uniforms, and custom suits.',
        'Offer premium options such as express delivery, custom neck designs, lining, finishing, and embroidery coordination.',
        'Store measurement history and past design photos for repeat customers.',
        'Use sample books or visual references so customers can choose styles faster and with fewer mistakes.',
      ],
    ),
    DomainRecommendation(
      category: 'Price',
      title: 'Separate base stitching from customization charges',
      description:
          'Tailoring is a skilled service, so margins can be healthier than retail product margins when pricing is structured properly.',
      actionPoints: [
        'Use price = labor time + tailoring materials + shop overhead + margin.',
        'Ask the owner to enter expected price for each job type so the app can compare quoted price with a minimum profitable price.',
        'Keep higher margins on design-heavy, urgent, bridal, or premium-fit work.',
        'Charge add-ons separately for piping, lining, embroidery coordination, alterations after delivery, and express orders.',
      ],
    ),
    DomainRecommendation(
      category: 'Place',
      title: 'Target repeat-fit neighborhoods and event demand',
      description:
          'The best place strategy is to build a strong local reputation where customers can return easily for trials and alterations.',
      actionPoints: [
        'Focus on apartments, family residential areas, schools, boutiques, and wedding-heavy localities nearby.',
        'Build referral links with fabric shops, saree stores, and boutiques in the same market.',
        'Offer pickup and drop only in nearby zones where alteration follow-up is still practical.',
        'Promote seasonal demand before festivals, school reopening, and wedding periods.',
      ],
    ),
    DomainRecommendation(
      category: 'Promotion',
      title: 'Promote craftsmanship and delivery trust',
      description:
          'Customers choose tailors when they believe the fitting will be correct and the order will be ready on time.',
      actionPoints: [
        'Show stitched samples, blouse patterns, alterations before-and-after, and customer feedback on social media.',
        'Put posters or small standees near fabric stores, saree shops, and women-focused shopping areas.',
        'Offer referral discounts for families or apartment groups that bring multiple orders.',
        'Send delivery reminders and festival offers to past customers using WhatsApp.',
      ],
    ),
    DomainRecommendation(
      category: 'Production',
      title: 'Manage order flow like a production pipeline',
      description:
          'Production for tailoring means order intake, cutting, stitching, trial, finishing, and delivery. Delays usually come from missing stage control.',
      actionPoints: [
        'Track each job stage clearly: measurement, cutting, stitching, trial, finishing, ready.',
        'Batch similar jobs together to reduce machine setup and mental switching.',
        'Keep daily targets for pending urgent orders and rework cases.',
        'Use delivery buffers so a small fitting issue does not break every promised date.',
      ],
    ),
    DomainRecommendation(
      category: '6Cs',
      title: 'Use the 6Cs to improve fit and loyalty',
      description:
          'Tailor shops benefit when customer records and process consistency become part of daily management.',
      actionPoints: [
        'Customer and convenience: save measurements, preferred cuts, and trial timings for repeat clients.',
        'Cost: review thread, lining, accessories, and labor cost for each order category.',
        'Communication: give realistic delivery dates and update customers if trials are needed.',
        'Consistency and competition: standardize stitching quality and compare your pricing with nearby boutiques and local tailors.',
      ],
    ),
  ];

  static const List<DomainRecommendation> _groceryRecommendations = [
    DomainRecommendation(
      category: 'Product',
      title: 'Shape assortment around daily essentials and profitable baskets',
      description:
          'For a grocery seller, the product is the mix of fast-moving essentials, trusted brands, and convenient pack sizes that match neighborhood demand.',
      actionPoints: [
        'Keep top essentials always available: atta, rice, oil, milk, bread, eggs, snacks, and cleaning items.',
        'Maintain a mix of low-ticket daily need items and higher-margin impulse products.',
        'Use local demand patterns to decide pack sizes for families, bachelors, and elderly customers.',
        'Track non-moving categories and reduce shelf space if they block better sellers.',
      ],
    ),
    DomainRecommendation(
      category: 'Price',
      title:
          'Keep lower margins on staples and stronger margins on convenience items',
      description:
          'Retail pricing works best when essentials stay competitive while convenience, premium, and impulse items carry better margins.',
      actionPoints: [
        'Use price = purchase cost + transport/loading cost + spoilage allowance + target margin.',
        'Ask the owner to enter intended selling price so the app can warn when the price is too low for profit or too high for local competition.',
        'Keep lower margins on staples like rice, sugar, flour, and oil because customers compare these strongly.',
        'Keep better margins on snacks, beverages, personal care, home delivery, repacking, and convenience items.',
      ],
    ),
    DomainRecommendation(
      category: 'Place',
      title: 'Win in the neighborhood before expanding',
      description:
          'Grocery demand is highly local. Place strategy should focus on areas that can be served quickly with repeat household purchases.',
      actionPoints: [
        'Prioritize nearby households, apartment clusters, hostels, and office pantry demand within easy delivery range.',
        'Offer quick phone or WhatsApp ordering for nearby repeat customers.',
        'Map which streets or buildings generate the highest monthly basket value.',
        'If home delivery is offered, keep a clear minimum order and service radius.',
      ],
    ),
    DomainRecommendation(
      category: 'Promotion',
      title: 'Promote convenience, freshness, and savings',
      description:
          'Grocery customers respond to reliability and practical offers. Promotion should help them remember that your store is nearby, stocked, and easy to order from.',
      actionPoints: [
        'Send WhatsApp lists for daily offers, fresh arrivals, and festival stock.',
        'Use posters, shop-front boards, and local apartment notices for free delivery or combo offers.',
        'Bundle slow-moving products with fast-moving categories to improve basket size.',
        'Run festival and month-start promotions when household stocking demand is highest.',
      ],
    ),
    DomainRecommendation(
      category: 'Production',
      title: 'Treat stock movement as the production engine',
      description:
          'Production for a grocery seller means buying, stocking, replenishing, and rotating inventory efficiently so money does not get stuck in dead stock.',
      actionPoints: [
        'Review fast-moving items daily and reorder before stock reaches emergency levels.',
        'Check expiry and damaged stock on a weekly rhythm, not only when shelves look full.',
        'Separate essential stock, seasonal stock, and experimental stock in your review process.',
        'Track wastage, returns, and shrinkage so hidden losses are visible.',
      ],
    ),
    DomainRecommendation(
      category: '6Cs',
      title: 'Use the 6Cs to improve repeat household business',
      description:
          'The 6Cs can keep a grocery business disciplined and customer-friendly.',
      actionPoints: [
        'Customer: understand whether your lane is family-heavy, student-heavy, or mixed.',
        'Cost and convenience: reduce stockouts on known repeat items and keep ordering simple on call or WhatsApp.',
        'Communication: inform regular buyers when key products are back in stock or on offer.',
        'Consistency and competition: keep stock reliability high and compare your staple pricing with nearby kirana stores and mini marts.',
      ],
    ),
  ];

  static const List<DomainRecommendation> _convenienceRecommendations = [
    DomainRecommendation(
      category: 'Product',
      title: 'Curate for urgent, quick-purchase needs',
      description:
          'A convenience store product mix should solve immediate need fast. Range should be simple, visible, and optimized for quick decisions.',
      actionPoints: [
        'Keep ready-to-buy categories strong: beverages, snacks, toiletries, medicines allowed by policy, and travel-size items.',
        'Place high-frequency products near entrance and counter for speed.',
        'Use smaller SKUs and grab-and-go packs for impulse buying.',
        'Refresh seasonal products such as rain items, exam snacks, and late-night essentials quickly.',
      ],
    ),
    DomainRecommendation(
      category: 'Price',
      title: 'Price for convenience while staying credible',
      description:
          'Customers accept slightly higher prices in convenience stores when service is fast and stock is dependable, but overpricing basics can damage trust.',
      actionPoints: [
        'Use price = purchase cost + logistics/handling + spoilage risk + target convenience margin.',
        'Ask the owner to enter suggested selling price, then compare it to typical margin bands for essential versus impulse categories.',
        'Keep modest margins on visible benchmark items like water bottles, bread, and milk.',
        'Keep stronger margins on impulse categories, ready-to-eat items, premium snacks, and late-hour convenience sales.',
      ],
    ),
    DomainRecommendation(
      category: 'Place',
      title: 'Target high-footfall micro-locations',
      description:
          'Place strategy for convenience stores depends on fast access. The strongest areas are where people need immediate items on the way home, to work, or during late hours.',
      actionPoints: [
        'Focus on busier pockets near apartments, petrol pumps, office roads, hostels, clinics, and transit points.',
        'Track which time blocks bring which customer type, then align assortment to that pattern.',
        'If delivery is offered, keep the delivery radius tight so urgent need remains your advantage.',
        'Adjust displays for school, office, and evening traffic depending on the location.',
      ],
    ),
    DomainRecommendation(
      category: 'Promotion',
      title: 'Promote speed and immediate availability',
      description:
          'Promotion should remind nearby buyers that your store is the fastest option, especially during late evening or urgent need situations.',
      actionPoints: [
        'Highlight quick-delivery, late-hours, or instant pickup availability on posters and local groups.',
        'Use bright storefront signage and counter displays to pull walk-in footfall.',
        'Run short social posts or WhatsApp updates for fresh stock, cold drinks, or emergency essentials.',
        'Offer apartment-specific contact cards so nearby residents remember where to call quickly.',
      ],
    ),
    DomainRecommendation(
      category: 'Production',
      title: 'Reduce friction in checkout and shelf refill',
      description:
          'Production here means how quickly stock moves from supplier to shelf to checkout. Delay at checkout or missing refill can cost easy sales.',
      actionPoints: [
        'Review shelf refill several times a day for high-turn items near the counter.',
        'Track shrinkage, damaged stock, and billing mismatch every week.',
        'Simplify SKU range when similar slow items create clutter and confuse customers.',
        'Prepare rush-hour staffing and payment flow for evening peaks.',
      ],
    ),
    DomainRecommendation(
      category: '6Cs',
      title: 'Use the 6Cs to stay sharp in a high-speed format',
      description:
          'Convenience stores win when speed and consistency are stronger than nearby alternatives.',
      actionPoints: [
        'Customer and convenience: understand whether you serve commuters, students, hostel residents, or families.',
        'Cost: watch leakages from shrinkage and dead stock because margins can disappear quietly.',
        'Communication: tell nearby customers what is available quickly and when fresh stock arrives.',
        'Consistency and competition: keep checkout fast and compare your assortment with nearby general stores and pharmacy-adjacent shops.',
      ],
    ),
  ];

  static const List<DomainRecommendation> _defaultRecommendations = [
    DomainRecommendation(
      category: 'Product',
      title: 'Define the core offering clearly',
      description:
          'Clarify what you sell, who it is for, and what makes your business more useful than nearby alternatives.',
      actionPoints: [
        'Keep a simple list of your top-selling and highest-margin offerings.',
        'Create basic, premium, and add-on options where possible.',
        'Collect customer feedback to improve quality and reduce complaints.',
        'Remove offerings that take effort but do not create enough value.',
      ],
    ),
    DomainRecommendation(
      category: 'Price',
      title: 'Set prices using cost plus margin',
      description:
          'Every price should cover direct cost, overhead share, and profit. Services can often carry higher margins than physical goods because the value includes skill and convenience.',
      actionPoints: [
        'Use price = direct cost + labor + overhead + desired margin.',
        'Ask the owner to enter the selling price they want, then compare it against the minimum profitable price.',
        'Keep lower margins on highly comparable products and stronger margins on skill-based or urgent offerings.',
        'Review prices whenever supplier cost or operating expense changes.',
      ],
    ),
    DomainRecommendation(
      category: 'Place',
      title: 'Focus on the right service area',
      description:
          'Growth usually improves when you serve the strongest local area first instead of trying to reach everyone.',
      actionPoints: [
        'List the neighborhoods or customer groups that buy most often.',
        'Track where repeat customers come from and target those pockets first.',
        'Only expand to new areas when demand is consistent and service quality can be maintained.',
        'Keep delivery or visit radius aligned with profit and time.',
      ],
    ),
    DomainRecommendation(
      category: 'Promotion',
      title: 'Promote consistently with local channels',
      description:
          'The best promotion is simple, repeatable, and visible where your customers already spend time.',
      actionPoints: [
        'Use WhatsApp, local groups, posters, referrals, and customer testimonials.',
        'Show proof of quality through photos, reviews, or customer stories.',
        'Run seasonal offers instead of continuous discounts.',
        'Follow up with past customers to encourage repeat business.',
      ],
    ),
    DomainRecommendation(
      category: 'Production',
      title: 'Improve execution and daily control',
      description:
          'Production means how well the business delivers on time with the right quality and minimum waste.',
      actionPoints: [
        'Track time, stock, and order status in a simple daily routine.',
        'Measure where delays, wastage, or rework are happening.',
        'Reserve capacity for high-value work and repeat demand.',
        'Review weekly performance to improve predictability.',
      ],
    ),
    DomainRecommendation(
      category: '6Cs',
      title: 'Use the 6Cs as a weekly management checklist',
      description:
          'Customer, cost, convenience, communication, consistency, and competition give a practical way to review business health.',
      actionPoints: [
        'Customer: know who buys most and why they return.',
        'Cost and convenience: protect profit while making buying easier.',
        'Communication: keep reminders, updates, and offers clear.',
        'Consistency and competition: deliver the same quality and track what nearby businesses are doing better.',
      ],
    ),
  ];
}
