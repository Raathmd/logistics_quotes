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
- [x] Create persisted resources with corrected relationships:
  - Organization (has_many :accounts, :branches, :users)
  - Account (belongs_to :organization) - used for API data restriction only
  - User (belongs_to :organization, :account, :branch) - primary relationship to org
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

## Next Steps Needed
- [ ] Debug server startup issues
- [ ] Create Ecto migrations for persisted resources
- [ ] Add seed data for testing (orgs, accounts, users, branches)
- [ ] Test API integration with real data
- [ ] Visit running app to verify functionality

## Relationship Structure (Corrected)
- Users belong to Organization (primary relationship)
- Users have selected Account (for API data filtering only)
- Organization has many Users, Accounts, Branches
- Account belongs to Organization (no direct user relationship)
