require_relative 'queries'

module ApiClient
  class PayloadBuilder
    SESSION_TOKEN = '041940cc850f0175'.freeze

    def self.search(address:, page_size:, check_in:, check_out:, lat:, lng:, rad:)
      {
        operationName: 'FullSearch',
        variables: {
          carouselLowCodeExp: false,
          input: {
            acidCarouselContext: nil,
            childrenAges: [],
            clientSideRequestId: "041940cc850f0175",
            dates: {
              checkin: check_in,
              checkout: check_out
            },
            doAvailabilityCheck: false,
            enableCampaigns: true,
            encodedAutocompleteMeta: nil,
            filters: {
              selectedFilters: "distance=#{rad}"
            },
            flexibleDatesConfig: {
              broadDatesCalendar: {
                checkinMonths: [],
                los: [],
                startWeekdays: []
              },
              dateFlexUseCase: "DATE_RANGE",
              dateRangeCalendar: {
                checkin: [check_in],
                checkout: [check_out]
              }
            },
            forcedBlocks: nil,
            location: {
              destType: "LATLONG",
              latitude: lat,
              longitude: lng,
              searchString: address
            },
            merchInput: {
              testCampaignIds: []
            },
            metaContext: {
              dragongateTraceId: nil,
              externalTotalPrice: nil,
              feedPrice: nil,
              hotelCenterAccountId: nil,
              metaCampaignId: 0,
              pricingProductsTag: nil,
              rateRuleId: nil
            },
            nbAdults: 1,
            nbChildren: 0,
            nbRooms: 1,
            needsRoomsMatch: false,
            optionalFeatures: {
              forceArpExperiments: true,
              testProperties: false
            },
            pagination: {
              offset: 0,
              rowsPerPage: page_size
            },
            referrerBlock: {
              blockName: "autocomplete",
              clickPosition: 0,
              clickType: "g"
            },
            sbCalendarOpen: false,
            selectedFilterSources: ["PREVIOUS"],
            seoThemeIds: [],
            showAparthotelAsHotel: true,
            sorters: {
              referenceGeoId: nil,
              selectedSorter: nil,
              tripTypeIntentId: nil
            },
            travelPurpose: 2,
            useSearchParamsFromSession: true,
            webSearchContext: {
              outcome: "SEARCH_RESULTS",
              reason: "CLIENT_SIDE_UPDATE",
              source: "SEARCH_RESULTS"
            }
          }
        },
        extensions: {},
        query: Queries::FULL_SEARCH
      }
    end

    def self.location(address)
      {
        operationName: 'SearchPlaces',
        variables: {
          fetchOnlyFirst: true,
          input: {
            searchString: address,
            sessionToken: SESSION_TOKEN
          }
        },
        extensions: {},
        query: Queries::SEARCH_PLACES
      }
    end
  end
end
