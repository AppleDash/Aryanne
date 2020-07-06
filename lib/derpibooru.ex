defmodule IrcBot.Derpibooru do
  @everything_filter_id "56027"

  def random_image!(query) do
    case random_image(query) do
      {:ok, image} -> image
    end
  end

  def random_image(query) do
    case get_json(
           "/search/images?filter_id=" <>
             @everything_filter_id <> "&q=" <> URI.encode(query) <> "&sf=random"
         ) do
      {:ok, %{"images" => images}} -> {:ok, Enum.at(images, 0)}
      err -> err
    end
  end

  defp get_json(path) do
    case HTTPoison.get("https://derpibooru.org/api/v1/json" <> path) do
      {:ok, %HTTPoison.Response{body: body}} -> {:ok, JSON.decode!(body)}
      err -> err
    end
  end
end
