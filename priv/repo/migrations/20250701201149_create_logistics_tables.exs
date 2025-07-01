defmodule LogisticsQuotes.Repo.Migrations.CreateLogisticsTables do
  use Ecto.Migration

  def change do
    # Create organizations table
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:code])

    # Create accounts table
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :active, :boolean, default: true, null: false

      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:code])
    create index(:accounts, [:organization_id])

    # Create branches table
    create table(:branches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :active, :boolean, default: true, null: false

      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:branches, [:code])
    create index(:branches, [:organization_id])

    # Create users table
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :username, :string, null: false
      add :active, :boolean, default: true, null: false
      add :last_seen_at, :utc_datetime

      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all),
        null: false

      add :account_id, references(:accounts, type: :binary_id, on_delete: :restrict), null: false
      add :branch_id, references(:branches, type: :binary_id, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
    create index(:users, [:organization_id])
    create index(:users, [:account_id])
    create index(:users, [:branch_id])
    create index(:users, [:last_seen_at])
  end
end
