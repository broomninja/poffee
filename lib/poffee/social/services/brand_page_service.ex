defmodule Poffee.Services.BrandPageService do
  @moduledoc """
  Context module for BrandPage
  """

  import Ecto.Query, warn: false

  alias Poffee.Repo

  alias Poffee.Accounts.User
  alias Poffee.Social.BrandPage

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @type uuid :: <<_::128>>

  @doc """
  Returns the list of brand_pages.

  ## Examples

      iex> list_brand_pages()
      [%BrandPage{}, ...]

  """

  def list_brand_pages do
    Repo.all(BrandPage)
  end

  @doc """
  Gets a single brand_page.

  Raises `Ecto.NoResultsError` if the Brand page does not exist.

  ## Examples

      iex> get_brand_page!(123)
      %BrandPage{}

      iex> get_brand_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand_page!(id), do: Repo.get!(BrandPage, id)

  @doc """
  Creates a brand_page.
  """
  @spec create_brand_page(map, User.t()) :: {:ok, BrandPage.t()} | changeset_error
  def create_brand_page(attrs \\ %{}, user) do
    attrs = Map.put(attrs, :owner_id, user.id)

    %BrandPage{}
    |> BrandPage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brand_page.

  ## Examples

      iex> update_brand_page(brand_page, %{field: new_value})
      {:ok, %BrandPage{}}

      iex> update_brand_page(brand_page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand_page(%BrandPage{} = brand_page, attrs) do
    brand_page
    |> BrandPage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a brand_page.

  ## Examples

      iex> delete_brand_page(brand_page)
      {:ok, %BrandPage{}}

      iex> delete_brand_page(brand_page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brand_page(%BrandPage{} = brand_page) do
    Repo.delete(brand_page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand_page changes.

  ## Examples

      iex> change_brand_page(brand_page)
      %Ecto.Changeset{data: %BrandPage{}}

  """
  def change_brand_page(%BrandPage{} = brand_page, attrs \\ %{}) do
    BrandPage.changeset(brand_page, attrs)
  end
end
