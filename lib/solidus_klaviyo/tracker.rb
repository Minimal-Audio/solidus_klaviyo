# frozen_string_literal: true

module SolidusKlaviyo
  class Tracker < SolidusTracking::Tracker
    class << self
      def from_config
        # Setup authorization
        KlaviyoAPI.configure do |config|
          config.api_key['Klaviyo-API-Key'] = "Klaviyo-API-Key #{SolidusKlaviyo.configuration.api_key}"
        end

        new(api_key: ::SolidusKlaviyo.configuration.api_key)
      end
    end

    # This method is called by SolidusTracking on `track` call
    def track(event)
      return unless valid_email?(event.customer_properties.try(:[], '$email'))

      payload = {
        data: {
          type: 'event',
          attributes: {
            properties: event.properties.merge({ name: event.name }),
            metric: {
              data: {
                type: 'metric',
                attributes: {
                  name: event.name
                }
              }
            },
            profile: {
              data: {
                type: 'profile',
                attributes: {
                  email: event.customer_properties['$email'],
                  properties: event.customer_properties
                }
              }
            }
          },
          time: event.time
        }
      }

      ::KlaviyoAPI::Events.create_event(payload)
    end

    # This method is called directly to send custom information
    def create_event(event_name, email, properties = {})
      return unless valid_email?(email)

      payload = {
        data: {
          type: 'event',
          attributes: {
            properties: properties.merge({ name: event_name }),
            metric: {
              data: {
                type: 'metric',
                attributes: {
                  name: event_name
                }
              }
            },
            profile: {
              data: {
                type: 'profile',
                attributes: {
                  email: email
                }
              }
            }
          }
        }
      }

      ::KlaviyoAPI::Events.create_event(payload)
    end

    private

    def valid_email?(email)
      email.present? && email != 'Unidentified'
    end
  end
end
