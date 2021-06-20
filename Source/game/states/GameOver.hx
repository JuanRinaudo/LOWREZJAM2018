package game.states;

import kha.Image;
import kha.Color;
import kext.AppState;
import kext.Application;
import kext.g2basics.Text;

import game.Player;

class GameOver extends AppState {

    private var text:Text;

    public function new() {
        super();

        text = new Text(0, 0, Application.width, Application.height, getGameoverText());
        text.fontSize = Data.ui.fontSize;
        text.lineSpacing = 0.75;
    
        Application.keyboard.onKeyReleased.add(goToGameState);
    }

    private function getGameoverText():String {
        var time = Math.floor(Player.time * 10) / 10;
        var souls = Math.floor(Player.totalSouls);
        var kills = Player.heroesKilled;
        return 'Total time:\n$time\nTotal Souls:\n$souls\nHero Kills:\n$kills';
    }

    private function goToGameState() {
        Application.keyboard.onKeyReleased.remove(goToGameState);
        Application.changeState(GameState);
    }

	private var clearColor:Color = Color.fromString("#FF000000");
    override public function render(backbuffer:Image) {
        clearTransformation2D(backbuffer);
        beginAndClear2D(backbuffer, clearColor);

        text.render(backbuffer);

        end2D(backbuffer);
    }

}