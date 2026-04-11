class DomainRecommendation {
  final String title;
  final String description;

  const DomainRecommendation({
    required this.title,
    required this.description,
  });
}

class DomainRecommendationService {
  const DomainRecommendationService();

  List<DomainRecommendation> getRecommendations(String? businessDomain) {
    switch ((businessDomain ?? '').trim().toLowerCase()) {
      case 'beauty parlor':
        return const [
          DomainRecommendation(
            title: 'Reduce No-Shows',
            description:
                'Confirm appointments a day in advance and keep a short waiting list so canceled slots can be filled quickly.',
          ),
          DomainRecommendation(
            title: 'Standardize Service Time',
            description:
                'Track how long common services take and set realistic time blocks so your day runs with fewer delays.',
          ),
          DomainRecommendation(
            title: 'Promote High-Margin Services',
            description:
                'Highlight services like facials, packages, or add-ons that take less material but bring better revenue.',
          ),
          DomainRecommendation(
            title: 'Track Product Usage',
            description:
                'Measure how much color, cream, or consumables are used per service so pricing stays profitable.',
          ),
          DomainRecommendation(
            title: 'Build Repeat Visits',
            description:
                'Record client preferences and remind customers when it is time for their next visit or refill service.',
          ),
          DomainRecommendation(
            title: 'Bundle Services',
            description:
                'Offer simple combos such as haircut plus cleanup or facial plus threading to increase average order value.',
          ),
        ];
      case 'tiffin services':
        return const [
          DomainRecommendation(
            title: 'Plan Menus Weekly',
            description:
                'Fix a weekly menu in advance so procurement is easier, waste is lower, and customers know what to expect.',
          ),
          DomainRecommendation(
            title: 'Batch Prep Ingredients',
            description:
                'Prepare masalas, chopped vegetables, and dough in bulk during low-pressure hours to reduce morning rush.',
          ),
          DomainRecommendation(
            title: 'Track Delivery Zones',
            description:
                'Group deliveries by area and assign time windows so fuel, travel time, and late deliveries are reduced.',
          ),
          DomainRecommendation(
            title: 'Separate Subscription and One-Time Orders',
            description:
                'Monitor recurring customers separately from ad hoc orders so you can predict volume more accurately.',
          ),
          DomainRecommendation(
            title: 'Measure Wastage Daily',
            description:
                'Compare cooked quantity to sold quantity every day to identify overproduction and protect margins.',
          ),
          DomainRecommendation(
            title: 'Collect Feedback on Taste and Portion Size',
            description:
                'A short feedback loop helps improve retention and lets you correct quality issues before customers leave.',
          ),
        ];
      case 'tailor shop':
        return const [
          DomainRecommendation(
            title: 'Track Order Status Clearly',
            description:
                'Keep each order marked as measurement taken, cutting, stitching, trial, or ready to reduce missed deadlines.',
          ),
          DomainRecommendation(
            title: 'Group Similar Jobs Together',
            description:
                'Batch alterations, blouse stitching, or finishing work so setup time is lower and productivity is higher.',
          ),
          DomainRecommendation(
            title: 'Keep Measurement History',
            description:
                'Saving repeat customer measurements reduces errors and speeds up future orders.',
          ),
          DomainRecommendation(
            title: 'Set Delivery Buffers',
            description:
                'Promise delivery with a small buffer so urgent rework does not affect all pending orders.',
          ),
          DomainRecommendation(
            title: 'Price Customization Separately',
            description:
                'Charge clearly for lining, embroidery, urgent delivery, or design changes so effort is not lost.',
          ),
          DomainRecommendation(
            title: 'Use Trial Appointments Well',
            description:
                'Schedule fittings in fixed slots to avoid interruptions during sewing hours.',
          ),
        ];
      case 'grocery seller':
        return const [
          DomainRecommendation(
            title: 'Reorder Fast-Moving Items Early',
            description:
                'Identify daily essentials that sell quickly and replenish them before they hit low stock.',
          ),
          DomainRecommendation(
            title: 'Review Margins by Category',
            description:
                'Compare profit across staples, snacks, beverages, and personal care to focus on stronger categories.',
          ),
          DomainRecommendation(
            title: 'Check Expiry Dates Regularly',
            description:
                'Create a simple weekly expiry check to reduce dead stock and prevent avoidable losses.',
          ),
          DomainRecommendation(
            title: 'Use Small Promotions on Slow Items',
            description:
                'Combine slower stock with popular products or run short offers to improve inventory movement.',
          ),
          DomainRecommendation(
            title: 'Encourage Digital Payments',
            description:
                'More digital payments can make bookkeeping easier and reduce end-of-day cash mismatch.',
          ),
          DomainRecommendation(
            title: 'Track Repeat Customer Needs',
            description:
                'Knowing common household purchase patterns helps you stock the right mix and improve loyalty.',
          ),
        ];
      case 'convenience store':
        return const [
          DomainRecommendation(
            title: 'Prioritize Speed at Checkout',
            description:
                'Keep top-selling essentials near the counter and reduce billing friction during busy hours.',
          ),
          DomainRecommendation(
            title: 'Stock for Immediate Need',
            description:
                'Focus shelf space on high-frequency, quick-purchase items that customers want urgently.',
          ),
          DomainRecommendation(
            title: 'Monitor Shrinkage',
            description:
                'Review missing stock, damaged items, and cash variance regularly to spot leakage early.',
          ),
          DomainRecommendation(
            title: 'Refresh Display Zones Often',
            description:
                'Move seasonal or impulse items to visible locations so customers notice them faster.',
          ),
          DomainRecommendation(
            title: 'Use Demand by Time of Day',
            description:
                'Track morning, afternoon, and evening purchase patterns to plan staffing and replenishment.',
          ),
          DomainRecommendation(
            title: 'Keep Basic Inventory Simple',
            description:
                'A shorter list of strong sellers is often more efficient than stocking too many low-moving options.',
          ),
        ];
      default:
        return const [
          DomainRecommendation(
            title: 'Track What Sells Best',
            description:
                'Review your most profitable products or services regularly so you can focus effort where returns are strongest.',
          ),
          DomainRecommendation(
            title: 'Reduce Manual Work',
            description:
                'Use consistent records for orders, stock, and payments so less time is spent remembering details.',
          ),
          DomainRecommendation(
            title: 'Build Customer Follow-Up',
            description:
                'Simple reminders, repeat offers, and feedback collection can improve retention for almost any business.',
          ),
          DomainRecommendation(
            title: 'Review Pricing Often',
            description:
                'Compare cost changes with your selling price so margins stay healthy as expenses change.',
          ),
          DomainRecommendation(
            title: 'Separate Urgent and Planned Work',
            description:
                'Keeping routine tasks separate from urgent ones helps your day stay predictable and efficient.',
          ),
          DomainRecommendation(
            title: 'Measure Weekly Performance',
            description:
                'A quick weekly review of sales, profit, and customer demand helps you spot improvement opportunities early.',
          ),
        ];
    }
  }
}
