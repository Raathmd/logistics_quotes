# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LogisticsQuotes.Repo.insert!(%LogisticsQuotes.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query
alias LogisticsQuotes.{Domain, Organization, Account, Branch, User}

# Clear existing data in reverse dependency order
LogisticsQuotes.Repo.delete_all(User)
LogisticsQuotes.Repo.delete_all(Branch)
LogisticsQuotes.Repo.delete_all(Account)
LogisticsQuotes.Repo.delete_all(Organization)

# Create organizations
{:ok, acme_org} =
  Ash.create!(
    Organization,
    %{
      name: "Acme Logistics Corp",
      code: "ACME",
      active: true
    },
    domain: Domain
  )

{:ok, global_org} =
  Ash.create!(
    Organization,
    %{
      name: "Global Transport Solutions",
      code: "GTS",
      active: true
    },
    domain: Domain
  )

# Create accounts for Acme
{:ok, acme_account1} =
  Ash.create!(
    Account,
    %{
      name: "ABC Shipping Ltd",
      code: "ABC001",
      organization_id: acme_org.id,
      active: true
    },
    domain: Domain
  )

{:ok, acme_account2} =
  Ash.create!(
    Account,
    %{
      name: "Express Logistics Inc",
      code: "EXP001",
      organization_id: acme_org.id,
      active: true
    },
    domain: Domain
  )

# Create accounts for Global
{:ok, global_account1} =
  Ash.create!(
    Account,
    %{
      name: "International Freight Co",
      code: "IFC001",
      organization_id: global_org.id,
      active: true
    },
    domain: Domain
  )

# Create branches for Acme
{:ok, acme_main} =
  Ash.create!(
    Branch,
    %{
      name: "Main Office",
      code: "MAIN",
      organization_id: acme_org.id,
      active: true
    },
    domain: Domain
  )

{:ok, acme_warehouse} =
  Ash.create!(
    Branch,
    %{
      name: "Warehouse A",
      code: "WHA",
      organization_id: acme_org.id,
      active: true
    },
    domain: Domain
  )

{:ok, acme_regional} =
  Ash.create!(
    Branch,
    %{
      name: "Regional Hub",
      code: "REG",
      organization_id: acme_org.id,
      active: true
    },
    domain: Domain
  )

# Create branches for Global
{:ok, global_hq} =
  Ash.create!(
    Branch,
    %{
      name: "Global HQ",
      code: "GHQ",
      organization_id: global_org.id,
      active: true
    },
    domain: Domain
  )

# Create users for Acme
{:ok, _john} =
  Ash.create!(
    User,
    %{
      name: "John Doe",
      email: "john.doe@acme.com",
      username: "john.doe",
      organization_id: acme_org.id,
      account_id: acme_account1.id,
      branch_id: acme_main.id,
      last_seen_at: DateTime.utc_now(),
      active: true
    },
    domain: Domain
  )

{:ok, _sarah} =
  Ash.create!(
    User,
    %{
      name: "Sarah Wilson",
      email: "sarah.wilson@acme.com",
      username: "sarah.wilson",
      organization_id: acme_org.id,
      account_id: acme_account1.id,
      branch_id: acme_main.id,
      last_seen_at: DateTime.utc_now(),
      active: true
    },
    domain: Domain
  )

{:ok, _mike} =
  Ash.create!(
    User,
    %{
      name: "Mike Johnson",
      email: "mike.johnson@acme.com",
      username: "mike.johnson",
      organization_id: acme_org.id,
      account_id: acme_account2.id,
      branch_id: acme_warehouse.id,
      last_seen_at: DateTime.utc_now(),
      active: true
    },
    domain: Domain
  )

{:ok, _emma} =
  Ash.create!(
    User,
    %{
      name: "Emma Davis",
      email: "emma.davis@acme.com",
      username: "emma.davis",
      organization_id: acme_org.id,
      account_id: acme_account1.id,
      branch_id: acme_regional.id,
      last_seen_at: DateTime.add(DateTime.utc_now(), -10, :minute),
      active: true
    },
    domain: Domain
  )

IO.puts("✅ Seed data created successfully!")
IO.puts("Organizations: #{Ash.count!(Organization, domain: Domain)}")
IO.puts("Accounts: #{Ash.count!(Account, domain: Domain)}")
IO.puts("Branches: #{Ash.count!(Branch, domain: Domain)}")
IO.puts("Users: #{Ash.count!(User, domain: Domain)}")
