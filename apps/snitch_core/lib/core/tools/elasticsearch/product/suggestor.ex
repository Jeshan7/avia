defmodule Snitch.Tools.ElasticSearch.Product.Suggestor do
  @moduledoc """
  Product Suggestion using elasticsearch

  Architecture reference : https://project-a.github.io/on-site-search-design-patterns-for-e-commerce/#index-pages-not-products
  """

  import Snitch.Tools.ElasticSearch.Product.Store, only: [search_products: 1]
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def perform(term) do
    %{
      "suggest" => %{
        "product-suggest" => [
          %{
            "options" => collection
          }
          | _
        ]
      }
    } =
      term
      |> convert_to_elastic_query
      |> search_products

    collection
  end

  defp convert_to_elastic_query(term) do
    %{
      "_source" => ["name", "brands", "category.direct_parent"],
      "suggest" => %{
        "product-suggest" => %{
          "prefix" => term,
          "completion" => %{
            "field" => "suggest_keywords",
            "size" => "10",
            "fuzzy" => true,
            "skip_duplicates" => "true",
            "contexts" => %{
              "tenant" => Repo.get_prefix()
            }
          }
        }
      }
    }
  end
end
