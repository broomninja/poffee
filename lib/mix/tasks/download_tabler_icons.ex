defmodule Mix.Tasks.DownloadTablerIcons do
  @shortdoc "Upgrade the icon set used by the application."

  @moduledoc """
  Upgrade the icon set used by the application.

  It fetches the most recent icons from [Tabler Icons](https://tabler-icons.io/),
  extracts them to the `vendor` directory and, then, runs a script to update some
  of the properties in the SVG files.

      $ mix download_tabler_icons

  """
  use Mix.Task
  require Logger

  @impl Mix.Task
  def run(_args) do
    {time, _} = :timer.tc(&update_icons/0)
    Mix.shell().info("Updated icons in #{time / 1_000_000} seconds")
  end

  defp update_icons do
    directory = Path.join([File.cwd!(), "assets/vendor/tabler/icons"])

    with {:error, _} <- File.ls(directory) do
      File.mkdir_p!(directory)
    end

    download_icons()
    for file <- File.ls!(directory), do: update_svg_file(Path.join([directory, file]))
  end

  defp update_svg_file(path) do
    with ".svg" <- Path.extname(path), {:ok, contents} <- File.read(path) do
      lines = contents |> String.split("\n") |> Enum.map(&update_svg_attributes(&1, path))
      new_contents = Enum.join(lines, "\n")
      File.write!(path, new_contents)
    end
  end

  defp update_svg_attributes(line, path) do
    file_name = Path.basename(path, ".svg")
    class_name = "class=\"icon icon-tabler icon-tabler-#{file_name}\" "
    size_name = "width=\"24\" height=\"24\" "

    line
    |> String.replace(class_name, "")
    |> String.replace(size_name, "")
    |> String.replace("stroke-width=\"2\"", "stroke-width=\"1.75\"")
  end

  # Downloads the icons from the Tabler Icons repository and extracts them to the `vendor` directory.
  defp download_icons do
    # get the latest version eg "2.20.0" from github
    cmd =
      "curl -Ls -o /dev/null -w %{url_effective}  https://github.com/tabler/tabler-icons/releases/latest | sed -n 's/.*tag\\/v//p'"

    {tabler_vsn, 0} = System.cmd("bash", ["-c", cmd], env: %{})

    Logger.info("Downloading version #{tabler_vsn}")

    cmd =
      "curl -s -L https://github.com/tabler/tabler-icons/archive/refs/tags/v#{tabler_vsn}.tar.gz | tar xzv -C assets/vendor/tabler --strip-components=1 tabler-icons-#{tabler_vsn}/icons"

    System.cmd("bash", ["-c", cmd], env: %{})
  end
end
