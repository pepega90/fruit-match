defmodule MatchingGameWeb.Live.Index do
  use MatchingGameWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="header">Memory Game</div>
    <div id="game-board" class="game-board">
      <%= for card <- @cards do %>
        <div class={card_class(card)}
             phx-click="flip_card"
             phx-value-id={card.id}>
        <%= if card.flipped or card.matched, do: card.value, else: "?" %>
        </div>
      <% end %>
    </div>
    <%= if @game_over do %>
    <div class="fixed inset-0 bg-gray-800 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg text-center">
        <h2 class="text-4xl font-bold text-green-600 mb-4">You Win!</h2>
        <p class="text-lg text-gray-700 mb-6">Congratulations, all the cards have been matched!</p>
        <button phx-click="restart_game" class="bg-blue-500 text-white py-2 px-4 rounded-lg hover:bg-blue-600 transition duration-200">
          Restart Game
        </button>
      </div>
    </div>
  <% end %>
    """
  end

  defp card_class(card) do
    cond do
      card.matched -> "card matched"
      card.flipped -> "card flipped"
      true -> "card hidden"
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    cards = [
      %{id: 1, value: "🍎", flipped: false, matched: false},
      %{id: 2, value: "🍌", flipped: false, matched: false},
      %{id: 3,value: "🍇", flipped: false, matched: false},
      %{id: 4,value: "🍓", flipped: false, matched: false},
      %{id: 5, value: "🍒", flipped: false, matched: false},
      %{id: 6, value: "🍍", flipped: false, matched: false},
      %{id: 7, value: "🍋", flipped: false, matched: false},
      %{id: 8, value: "🍊", flipped: false, matched: false},
      %{id: 9, value: "🍎", flipped: false, matched: false},
      %{id: 10,value: "🍌", flipped: false, matched: false},
      %{id: 11,value: "🍇", flipped: false, matched: false},
      %{id: 12,value: "🍓", flipped: false, matched: false},
      %{id: 13,value: "🍒", flipped: false, matched: false},
      %{id: 14,value: "🍍", flipped: false, matched: false},
      %{id: 15,value: "🍋", flipped: false, matched: false},
      %{id: 16,value: "🍊", flipped: false, matched: false}
    ]
    shuffled_cards = Enum.shuffle(cards)
    {:ok, assign(socket, cards: shuffled_cards, flipped_cards: [],  game_over: false)}
  end

  @impl true
  def handle_event("restart_game", _params, %{assigns: %{cards: cards}} = socket) do
    updated_cards = cards |> Enum.map(fn c ->
      Map.update(c, :matched, false, fn _ -> false end) |> Map.update(:flipped, false, fn _ -> false end)
  end)
    shuffle_cards = Enum.shuffle(updated_cards)
    {:noreply, socket |> assign(cards: shuffle_cards, flipped_cards: [], game_over: false)}
  end
  @impl true
  def handle_event("flip_card", %{"id" => id_card}, %{assigns: %{flipped_cards: flipped_cards, cards: cards}} = socket) do
    # todo
    # ubah property flippednya jadi tru dari selected_card
    # setelah itu update cards array
    # lalu push laa ke flipped_cards
    # nah card pertama sudah ter push dengan flipped true
    # lalu lakukan lagi dengan card ke dua
    # jika length dari flipped_cards == 2, cek kedua cards, apakah valuenya sama
    # jika sama maka buat property matchednya true
    # jika tidak sama, balikin lagi ke hidden
    updated_cards = cards |>
                    Enum.map(fn card ->
                      if card.id == id_card |> String.to_integer() do
                        Map.update(card, :flipped, true, fn _ -> true end)
                      else
                        card
                      end
                    end)
    selected_card = cards |> Enum.find(fn e -> e.id == id_card |> String.to_integer() end)
    updated_flipped_cards = [selected_card | flipped_cards]
    if length(updated_flipped_cards) == 2 do
      Process.send_after(self(), :timeout, 800)
    # else
    #   updated_flipped_cards
    end
    {:noreply, socket |> assign(flipped_cards: updated_flipped_cards,cards: updated_cards)}
  end

  @impl true
  def handle_info(:timeout, %{assigns: %{cards: cards, flipped_cards: list_flip}} = socket) do
    [card1, card2] = list_flip |> Enum.take(2)
    if card1.value == card2.value and card1.id != card2.id do
        updated_match_cards = cards |> Enum.map(fn card ->
          cond do
            card.id == card1.id or card.id == card2.id ->
              Map.update(card, :matched, true, fn _ -> true end)
            true ->
              card
          end
      end)
      {:noreply, socket |> assign(cards: updated_match_cards, flipped_cards: [], game_over: Enum.all?(updated_match_cards, fn card -> card.matched end))}
    else
      flipped_all_cards = cards |> Enum.map(fn card ->
        if card.flipped do
          Map.update(card, :flipped, false, fn _ -> false end)
        else
          card
        end
      end)
      {:noreply, socket |> assign(cards: flipped_all_cards, flipped_cards: [])}
    end
  end
end
