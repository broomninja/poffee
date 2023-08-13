defmodule Poffee.UtilsTest do
  use Poffee.DataCase, async: false

  alias Poffee.Utils

  describe "utils" do
    test "blank?/1" do
      assert true == Utils.blank?(nil)
      assert true == Utils.blank?("")
      assert true == Utils.blank?("   ")
      assert false == Utils.blank?("text")
    end

    test "normalize_string/1" do
      assert nil == Utils.normalize_string(nil)
      assert nil == Utils.normalize_string("")
      assert nil == Utils.normalize_string("  ")
      assert "some string" == Utils.normalize_string(" some string ")
    end

    test "is_non_empty_list?/1" do
      assert false == Utils.is_non_empty_list?(nil)
      assert false == Utils.is_non_empty_list?([])
      assert true == Utils.is_non_empty_list?([1])
      assert true == Utils.is_non_empty_list?([1, 2])
    end

    test "maybe_if/3" do
      assert 20 == Utils.maybe_if(10, true, fn x -> x * 2 end)
      assert 10 == Utils.maybe_if(10, false, fn x -> x * 2 end)
    end

    test "valid_local_url?/1" do
      assert false == Utils.valid_local_url?(nil)
      assert false == Utils.valid_local_url?("")
      assert false == Utils.valid_local_url?("https://somewebsite.com/path")
      assert true == Utils.valid_local_url?("/local/path/x.html")
    end

    test "ip_tuple_to_string/1" do
      assert nil == Utils.ip_tuple_to_string(nil)
      assert "202.1.22.4" == Utils.ip_tuple_to_string({202, 1, 22, 4})
    end

    test "can_be_cached?/1" do
      assert false == Utils.can_be_cached?(nil)
      assert false == Utils.can_be_cached?({:error, "reason"})
      assert false == Utils.can_be_cached?({:ok, nil})
      assert false == Utils.can_be_cached?({:ok, []})
      assert false == Utils.can_be_cached?([])
      assert true == Utils.can_be_cached?({:ok, "value"})
      assert true == Utils.can_be_cached?(100)
    end

    test "get_modal_name/2" do
      assert "live-login-modal" == Utils.get_modal_name(nil, "")

      assert "logged-in-modal" ==
               Utils.get_modal_name(%Poffee.Accounts.User{id: "123"}, "logged-in-modal")
    end

    test "get_field/2" do
      assert nil == Utils.get_field(nil, "")
      assert 123 == Utils.get_field(%{some_field: 123}, :some_field)
      assert nil == Utils.get_field(%{some_field: 123}, :non_existent_field)
    end

    test "stringify_keys/3" do
      assert nil == Utils.stringify_keys(nil)
      assert %{"k" => "value"} == Utils.stringify_keys(%{k: "value"})
      assert %{"k1" => %{"k2" => "value"}} == Utils.stringify_keys(%{k1: %{k2: "value"}})
    end
  end
end
