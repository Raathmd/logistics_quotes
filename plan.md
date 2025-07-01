# Logistics Quotes Management System Plan

## Dashboard Features
- [x] Generate Phoenix LiveView project `logistics_quotes`
- [x] Add Ash dependencies (ash, ash_phoenix, ash_postgres, decimal)
- [x] Create plan.md (skipping server start for now)
- [x] Replace home page with static dashboard mockup showing:
  - Online users by branch within organization
  - Quote search form interface
  - Professional logistics design

## Persisted Ash Resources & Domain
- [x] Create Ash domain (LogisticsQuotes.Domain)
- [x] Create persisted resources with relationships:
  - Organization (has_many :accounts, :branches)
  - Account (belongs_to :organization, has_many :users)
  - User (belongs_to :account, belongs_to :branch)
  - Branch (belongs_to :organization)
  - Add presence tracking for online users

## Non-Persisted Quote Resources (Embedded)
- [x] Create embedded quote resources:
  - Quote (with items, sundries, rates)
  - QuoteItem, QuoteSundry, QuoteRate
  - Input validation schemas only

## API Integration with FreightWare Auth
- [x] Create FreightWareAPI HTTP client with fw_login authentication
- [x] Complete manual actions using token auth:
  - SearchQuotes, QuickQuote, CreateQuote

## LiveView Dashboard Interface
- [x] Create main DashboardLive with:
  - Real-time online users display by branch
  - Quote search form with API integration
  - Account selection constraint for multi-tenancy

## Integration & Polish
- [x] Wire API actions to LiveView events
- [x] Update layouts for professional logistics design
- [x] Update router and test functionality
- [ ] Visit running app to verify - 1 step reserved for debugging

