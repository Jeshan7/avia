defmodule Snitch.Data.Schema.HostedPaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.HostedPayment

  setup do
    [
      user: insert(:user),
      order: insert(:order)
    ]
  end

  setup :payment_methods
  setup :payments

  test "create_changeset/2 refer hosted payment uniquely", context do
    %{hpm: hosted_payment} = context
    insert(:hosted_payment, payment_id: hosted_payment.id)

    hosted_payment =
      HostedPayment.create_changeset(%HostedPayment{}, %{
        transaction_id: "1234abc",
        payment_id: hosted_payment.id
      })

    assert {:error, cs} = Repo.insert(hosted_payment)
    assert %{payment_id: ["has already been taken"]} = errors_on(cs)
  end

  test "create exclusivity for hosted payment", context do
    %{chk: check} = context

    hosted_payment =
      HostedPayment.create_changeset(%HostedPayment{}, %{
        transaction_id: "1234abc",
        payment_id: check.id
      })

    assert {:error, cs} = Repo.insert(hosted_payment)
    assert %{payment_id: ["does not refer a hosted payment"]} = errors_on(cs)
  end
end
