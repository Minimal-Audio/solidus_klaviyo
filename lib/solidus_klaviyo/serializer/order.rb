# frozen_string_literal: true

module SolidusKlaviyo
  module Serializer
    class Order < Base
      def order
        object
      end

      def as_json(_options = {})
        {
          'OrderNumber' => order.number,
          'Categories' => (order.line_items.flat_map do |line_item|
            line_item.variant.product.taxons.flat_map(&:self_and_ancestors)
          end).uniq.map(&:name),
          'ItemNames' => order.line_items.map { |line_item| line_item.variant.descriptive_name },
          'DiscountCode' => order.order_promotions.map { |op| op.code.value }.join(', '),
          'DiscountValue' => order.promo_total,
          'Items' => order.line_items.map { |line_item| LineItem.serialize(line_item) },
          'BillingAddress' => Address.serialize(order.bill_address),
          'ShippingAddress' => Address.serialize(order.ship_address),
          'OrderURL' => order_url,
          'Total' => order.total,
          'ItemTotal' => order.item_total,
          'AdjustmentTotal' => order.adjustment_total,
          'PaymentTotal' => order.payment_total,
          'ShipmentTotal' => order.shipment_total,
          'AdditionalTaxTotal' => order.additional_tax_total,
          'PromoTotal' => order.promo_total,
          'IncludedTaxTotal' => order.included_tax_total,
        }
      end

      def order_url
        SolidusKlaviyo.configuration.order_url_builder.call(order)
      end
    end
  end
end
