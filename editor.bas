OPTION BASE 1

w = window()
w.SetSize(1000, 870)
w.SetFont(10, "px", 0, 0)
delay(500)

'import ButtonUnit as Button

const TILES_BG_X                = 30
const TILES_BG_Y                = 9
const TileSize                  = 32
const BOARD_SIZE_X              = 30
const BOARD_SIZE_Y              = 15
const BUTTON_SIZE               = 32
const PATH_TO_DATA              = "./DATA/"
      Tile_Set_File             = "TILESET1.TXT"
      Level_Name                = PATH_TO_DATA + "/LEVELS/LEVEL001.TXT"
const NUMBER_OF_BONUSES         = 4
const NUMBER_OF_EXIT            = 4
const NUMBER_OF_ENEMIES         = 2
const COLOR_BLACK               = rgb(0,0,0)
const COLOR_WHITE               = rgb(255,255,255)
const COLOR_RED                 = rgb(255,0,0)
const COLOR_GREEN               = rgb(0,255,0)

dim Board
dim Tiles
dim BoardButtons
dim Buttons_AllTiles
dim Buttons_Bonus
dim Buttons_Exit
dim Buttons_Player
dim Buttons_Tools
dim Buttons_Enemy
Buttons_AllTiles_Selected = 1
Buttons_Bonus_Selected = 0
Buttons_Exit_Selected = 0
Buttons_Player_Selected = 0
Buttons_Tools_Selected = 0
Buttons_Enemy_Selected = 0

Player      = {PositionX:1,PositionY:1, Tile: 1, TileUp:1, TileDown:1, TileLeft:1, TileRight:1}
Bonus       = {TileBonus1:1, TileBonus2:1, TileBonus3:1, TileBonusLive:1}
LevelExit   = {TileUp:1, TileDown:1, TileLeft:1, TileRight:1}
Enemy       = {TileEnemy1:1, TileEnemy2:1}
ZeroTile    = 0
LoadSavePath = PATH_TO_DATA + "/LEVELS"

Selection = 0
const SELECTION_TYPE_BG_TILE = 1
const SELECTION_TYPE_BONUS_1 = 2
const SELECTION_TYPE_BONUS_2 = 3
const SELECTION_TYPE_BONUS_3 = 4
const SELECTION_TYPE_BONUS_LIVE = 5
const SELECTION_TYPE_EXIT_UP = 6
const SELECTION_TYPE_EXIT_DOWN = 7
const SELECTION_TYPE_EXIT_LEFT = 8
const SELECTION_TYPE_EXIT_RIGHT = 9
const SELECTION_TYPE_ZERO = 10
const SELECTION_TYPE_PLAYER_UP = 11
const SELECTION_TYPE_PLAYER_DOWN = 12
const SELECTION_TYPE_PLAYER_LEFT = 13
const SELECTION_TYPE_PLAYER_RIGHT = 14
const SELECTION_TYPE_TOOLS_LOAD = 16
const SELECTION_TYPE_TOOLS_DELBONUS = 17
const SELECTION_TYPE_TOOLS_DELEXIT = 18
const SELECTION_TYPE_TOOLS_DELTRAP = 19
const SELECTION_TYPE_TOOLS_DELTILE = 20
const SELECTION_TYPE_TOOLS_SETTRAP = 21
const SELECTION_TYPE_TOOLS_DELBLOCK = 22
const SELECTION_TYPE_TOOLS_SETBLOCK = 23
const SELECTION_TYPE_ENEMY_1 = 24
const SELECTION_TYPE_ENEMY_2 = 25
const SELECTION_TYPE_TOOLS_DELENEMY = 26
const SELECTION_TYPE_TOOLS_NEW = 27

LoadTiles()
CreateBoard()
CreateAllTileSelection()
CreateBonusTileSelection()
CreateLevelExitTileSelection()
CreatePlayerTileSelection()
CreateTools()
CreateEnemyTileSelection()
Player.Tile = Player.TileRight
DrawBoard()


pen on

while(1)

    if(pen(3))
    
        ButtonNumber = CheckButtonPressed(Buttons_AllTiles)
        if(ButtonNumber) then 
            
            UnsetButtonHighlight()           
            
            Buttons_AllTiles[ButtonNumber].LineColor = rgb(255,255,255)
            ButtonShow(Buttons_AllTiles[ButtonNumber])
            Buttons_AllTiles_Selected = ButtonNumber
            
            Selection = SELECTION_TYPE_BG_TILE
        
        endif
        
        ButtonNumber = CheckButtonPressed(Buttons_Exit)
        if(ButtonNumber) then 
            
            UnsetButtonHighlight()           
            
            Buttons_Exit[ButtonNumber].LineColor = rgb(255,255,255)
            ButtonShow(Buttons_Exit[ButtonNumber])
            Buttons_Exit_Selected = ButtonNumber
        
            select case ButtonNumber
                case 1: Selection = SELECTION_TYPE_EXIT_UP
                case 2: Selection = SELECTION_TYPE_EXIT_DOWN
                case 3: Selection = SELECTION_TYPE_EXIT_LEFT
                case 4: Selection = SELECTION_TYPE_EXIT_RIGHT
            end select
        
        endif
        
        ButtonNumber = CheckButtonPressed(Buttons_Player)
        if(ButtonNumber) then 
            
            UnsetButtonHighlight()           
            
            Buttons_Player[ButtonNumber].LineColor = rgb(255,255,255)
            ButtonShow(Buttons_Player[ButtonNumber])
            Buttons_Player_Selected = ButtonNumber
            
            select case ButtonNumber
                case 1: Selection = SELECTION_TYPE_PLAYER_UP
                case 2: Selection = SELECTION_TYPE_PLAYER_DOWN
                case 3: Selection = SELECTION_TYPE_PLAYER_LEFT
                case 4: Selection = SELECTION_TYPE_PLAYER_RIGHT
            end select
        
        endif
        
        ButtonNumber = CheckButtonPressed(Buttons_Bonus)
        if(ButtonNumber) then
            
            UnsetButtonHighlight()
                       
            Buttons_Bonus[ButtonNumber].LineColor = rgb(255,255,255)
            ButtonShow(Buttons_Bonus[ButtonNumber])
            Buttons_Bonus_Selected = ButtonNumber
            
            select case ButtonNumber
                case 1: Selection = SELECTION_TYPE_BONUS_1
                case 2: Selection = SELECTION_TYPE_BONUS_2
                case 3: Selection = SELECTION_TYPE_BONUS_3
                case 4: Selection = SELECTION_TYPE_BONUS_LIVE
            end select
                    
        endif
        
        ButtonNumber = CheckButtonPressed(Buttons_ENEMY)
        if(ButtonNumber) then
            
            UnsetButtonHighlight()
                       
            Buttons_Enemy[ButtonNumber].LineColor = rgb(255,255,255)
            ButtonShow(Buttons_Enemy[ButtonNumber])
            Buttons_Enemy_Selected = ButtonNumber
            
            select case ButtonNumber
                case 1: Selection = SELECTION_TYPE_ENEMY_1
                case 2: Selection = SELECTION_TYPE_ENEMY_2
            end select
                    
        endif
        
        ButtonNumber = CheckButtonPressed(Buttons_Tools)
        if(ButtonNumber) then 
            UnsetButtonHighlight()           
            
            Buttons_Tools[ButtonNumber].LineColor = rgb(255,255,255)
            ButtonShow(Buttons_Tools[ButtonNumber])
            Buttons_Tools_Selected = ButtonNumber
            
            select case ButtonNumber
                case  1: NewLevel()
                case  2: SaveLevel()                    
                case  3: LoadLevel()
                case  4: Selection = SELECTION_TYPE_TOOLS_DELTILE
                case  5: Selection = SELECTION_TYPE_TOOLS_DELBONUS
                case  6: Selection = SELECTION_TYPE_TOOLS_DELEXIT
                case  7: Selection = SELECTION_TYPE_TOOLS_SETTRAP
                case  8: Selection = SELECTION_TYPE_TOOLS_DELTRAP
                case  9: Selection = SELECTION_TYPE_TOOLS_SETBLOCK
                case 10: Selection = SELECTION_TYPE_TOOLS_DELBLOCK
                case 11: Selection = SELECTION_TYPE_TOOLS_DELENEMY
            end select
        
        endif
        
        ButtonNumber = CheckButtonPressed(BoardButtons)
        if(ButtonNumber) then
            
            select case Selection
                case SELECTION_TYPE_BG_TILE
                    Board[ButtonNumber].BG_Tile = Buttons_AllTiles_Selected
                    Board[ButtonNumber].Block = 0
                case SELECTION_TYPE_BONUS_1
                    Board[ButtonNumber].Bonus_Tile = Bonus.TileBonus1
                    Board[ButtonNumber].Bonus_Name = 1
                case SELECTION_TYPE_BONUS_2
                    Board[ButtonNumber].Bonus_Tile = Bonus.TileBonus2
                    Board[ButtonNumber].Bonus_Name = 2
                case SELECTION_TYPE_BONUS_3
                    Board[ButtonNumber].Bonus_Tile = Bonus.TileBonus3
                    Board[ButtonNumber].Bonus_Name = 3
                case SELECTION_TYPE_BONUS_LIVE
                    Board[ButtonNumber].Bonus_Tile = Bonus.TileBonusLive
                    Board[ButtonNumber].Bonus_Name = 4
                case SELECTION_TYPE_EXIT_UP
                    Board[ButtonNumber].Exit_Tile = LevelExit.TileUp
                case SELECTION_TYPE_EXIT_DOWN
                    Board[ButtonNumber].Exit_Tile = LevelExit.TileDown
                case SELECTION_TYPE_EXIT_LEFT
                    Board[ButtonNumber].Exit_Tile = LevelExit.TileLeft
                case SELECTION_TYPE_EXIT_RIGHT
                    Board[ButtonNumber].Exit_Tile = LevelExit.TileRight
                case SELECTION_TYPE_PLAYER_UP
                    Player.Tile = Player.TileUp
                    Player.PositionY = ceil(ButtonNumber / BOARD_SIZE_X)
                    Player.PositionX = ((ButtonNumber - 1) % (BOARD_SIZE_X)) + 1
                case SELECTION_TYPE_PLAYER_DOWN
                    Player.Tile = Player.TileDown
                    Player.PositionY = ceil(ButtonNumber / BOARD_SIZE_X)
                    Player.PositionX = ((ButtonNumber - 1) % (BOARD_SIZE_X)) + 1
                case SELECTION_TYPE_PLAYER_LEFT
                    Player.Tile = Player.TileLeft
                    Player.PositionY = ceil(ButtonNumber / BOARD_SIZE_X)
                    Player.PositionX = ((ButtonNumber - 1) % (BOARD_SIZE_X)) + 1
                case SELECTION_TYPE_PLAYER_RIGHT
                    Player.Tile = Player.TileRight
                    Player.PositionY = ceil(ButtonNumber / BOARD_SIZE_X)
                    Player.PositionX = ((ButtonNumber - 1) % (BOARD_SIZE_X)) + 1
                case SELECTION_TYPE_TOOLS_DELTILE
                    Board[ButtonNumber].BG_Tile = ZeroTile
                case SELECTION_TYPE_TOOLS_DELBONUS
                    Board[ButtonNumber].Bonus_Tile = 0
                    Board[ButtonNumber].Bonus_Name = 0
                case SELECTION_TYPE_TOOLS_DELEXIT
                    Board[ButtonNumber].Exit_Tile = 0
                case SELECTION_TYPE_TOOLS_SETTRAP
                    Board[ButtonNumber].TRAP = 1
                case SELECTION_TYPE_TOOLS_DELTRAP
                    Board[ButtonNumber].TRAP = 0
                case SELECTION_TYPE_TOOLS_SETBLOCK
                    Board[ButtonNumber].Block = 1
                case SELECTION_TYPE_TOOLS_DELBLOCK
                    Board[ButtonNumber].Block = 0
                case SELECTION_TYPE_TOOLS_DELENEMY
                    Board[ButtonNumber].Enemy_Tile = 0
                    Board[ButtonNumber].Enemy_Name = 0                    
                case SELECTION_TYPE_ENEMY_1
                    Board[ButtonNumber].Enemy_Tile = Enemy.TileEnemy1
                    Board[ButtonNumber].Enemy_Name = 1
                case SELECTION_TYPE_ENEMY_2
                    Board[ButtonNumber].Enemy_Tile = Enemy.TileEnemy2
                    Board[ButtonNumber].Enemy_Name = 2
            end select
            
            DrawBoard()
            
            
                    
        endif
        
    endif
    
    showpage
    delay(20)
wend



'####################################################

sub NewLevel()
    w.ask("The level will be reseted. Are you sure?", "Create New Level")

    if(w.answer == 0)
        CreateBoard()
        DrawBoard()
    endif    
 
end

sub LoadLevel()
    local FileNames, ii, f, CurrentDirectory
    
    CurrentDirectory = cwd
    chdir(LoadSavePath)

    showpage(1)
    Level_Name = FileSelectDialog(0, 25, 25, XMAX-50, YMAX - 50, 0)
    showpage

    
    LoadSavePath = cwd
    chdir(CurrentDirectory)
    if(Level_Name == -1) then exit
    
    tload Level_Name, d
    
    ' Do simple check if selected file is a valid level file
    if(disclose(d[1], "\"\"") != "TileSet") then
        w.alert("Not a valid level file")
        exit 
    endif
    
    temp = array(d[1])
        
    Tile_Set_File = temp.TileSet    
    
    LoadTiles()
    CreateAllTileSelection()
    CreateBonusTileSelection()
    CreateEnemyTileSelection()
    CreateLevelExitTileSelection()
    CreatePlayerTileSelection()
    CreateTools()
    
    temp = array(d[2])    
    Player.Tile = temp.PlayerTile    
    Player.PositionX = temp.PlayerX
    Player.PositionY = temp.PlayerY
    
    dim Board
    ii = 2
    for yy = 1 to BOARD_SIZE_Y
        for xx = 1 to BOARD_SIZE_X
            ii++
            temp = array(d[ii])
            temp1.BG_Tile = temp.BG_Tile
            temp1.Bonus_Tile = temp.Bonus_Tile
            temp1.Bonus_Name = temp.Bonus_Name
            temp1.Exit_Tile = temp.Exit_Tile
            temp1.Trap = temp.Trap
            temp1.Block = temp.Block
            temp1.Enemy_Tile = temp.Enemy_Tile
            temp1.Enemy_Name = temp.Enemy_Name
            Board << temp1
        next
    next 
    
    DrawBoard()
    

end

sub SaveLevel()
    local TempBoard, TempPlayer, f, TileSet
    
    TempBoard = Board
    TempPlayer.PlayerX = Player.PositionX
    TempPlayer.PlayerY = Player.PositionY
    TempPlayer.PlayerTile = Player.Tile

    TileSet.TileSet = TILE_SET_FILE

    CurrentDirectory = cwd
    chdir(LoadSavePath)

    showpage
    delay(100)
    showpage(1)
    Level_Name = FileSelectDialog(1, 100, 100, XMAX-200, YMAX - 200, 0)
    showpage

    LoadSavePath = cwd
    chdir(CurrentDirectory)
    if(Level_Name == -1) then exit

    insert TempBoard, 1, TempPlayer    
    insert TempBoard, 1, TileSet
    tsave Level_Name, TempBoard
    
    DrawBoard()
end

sub UnsetButtonHighlight()
        
    if(Buttons_AllTiles_Selected)            
        Buttons_AllTiles[Buttons_AllTiles_Selected].LineColor = rgb(100,100,100)
        ButtonShow(Buttons_AllTiles[Buttons_AllTiles_Selected])
    endif
    if(Buttons_Bonus_Selected)            
        Buttons_Bonus[Buttons_Bonus_Selected].LineColor = rgb(100,100,100)
        ButtonShow(Buttons_Bonus[Buttons_Bonus_Selected])
    endif
    if(Buttons_Exit_Selected)            
        Buttons_Exit[Buttons_Exit_Selected].LineColor = rgb(100,100,100)
        ButtonShow(Buttons_Exit[Buttons_Exit_Selected])
    endif
    if(Buttons_Player_Selected)            
        Buttons_Player[Buttons_Player_Selected].LineColor = rgb(100,100,100)
        ButtonShow(Buttons_Player[Buttons_Player_Selected])
    endif
    if(Buttons_Tools_Selected)            
        Buttons_Tools[Buttons_Tools_Selected].LineColor = rgb(100,100,100)
        ButtonShow(Buttons_Tools[Buttons_Tools_Selected])
    endif
    if(Buttons_Enemy_Selected)            
        Buttons_Enemy[Buttons_Enemy_Selected].LineColor = rgb(100,100,100)
        ButtonShow(Buttons_Enemy[Buttons_Enemy_Selected])
    endif

end

func CheckButtonPressed(byref T)
    local b, ii
    ii = 0
    for b in T
        ii++
        if(ButtonIsPressedAgain(b)) then
            ' b got modified. but b is not a pointer to the array element,
            ' -> the array element needs to be updated
            T[ii] = b  
            return ii
        endif
        
    next
    
    return 0
end

sub CreateTools()
   
    local ButtonGrid, temp
    dim Buttons_Tools

    ButtonGrid = ButtonCreateGrid(0, BOARD_SIZE_Y * (BUTTON_SIZE + 1), BUTTON_SIZE * 20, BOARD_SIZE_Y * (BUTTON_SIZE + 3), 12, 1)
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 1, 0, "NEW")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500    
    ButtonShow(temp)
    Buttons_Tools << temp
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 2, 0, "SAVE")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500    
    ButtonShow(temp)
    Buttons_Tools << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 3, 0, "LOAD")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 4, 0, "DEL TILE")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 5, 0, "DEL BONUS")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 6, 0, "DEL EXIT")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 7, 0, "SET TRAP")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 8, 0, "DEL TRAP")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 9, 0, "SET BLOCK")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 10, 0, "DEL BLOCK")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp
    
    temp = ButtonCreateByGrid(ButtonGrid, 1, 11, 0, "DEL ENMY")
    temp.LineColor = rgb(100,100,100)
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Tools << temp

end

sub CreatePlayerTileSelection()
    local ButtonGrid, temp
    dim Buttons_Player
    
    ButtonGrid = ButtonCreateGrid((BUTTON_SIZE * 8), BOARD_SIZE_Y * (BUTTON_SIZE + 4), 3*BUTTON_SIZE * NUMBER_OF_BONUSES, BOARD_SIZE_Y * (BUTTON_SIZE + 6), NUMBER_OF_BONUSES, 1)
    temp = ButtonCreateByGrid(ButtonGrid, 1, 1, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Player.TileUp]
    temp.DebounceTime = 500    
    ButtonShow(temp)
    Buttons_Player << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 2, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Player.TileDown]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Player << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 3, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Player.TileLeft]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Player << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 4, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Player.TileRight]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Player << temp

end


sub CreateBonusTileSelection()
    local ButtonGrid, temp
    dim Buttons_Bonus

    ButtonGrid = ButtonCreateGrid(0, BOARD_SIZE_Y * (BUTTON_SIZE + 4), BUTTON_SIZE * NUMBER_OF_BONUSES, BOARD_SIZE_Y * (BUTTON_SIZE + 6), NUMBER_OF_BONUSES, 1)
    temp = ButtonCreateByGrid(ButtonGrid, 1, 1, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Bonus.TileBonus1]
    temp.DebounceTime = 500    
    ButtonShow(temp)
    Buttons_Bonus << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 2, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Bonus.TileBonus2]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Bonus << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 3, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Bonus.TileBonus3]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Bonus << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 4, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Bonus.TileBonusLive]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Bonus << temp
end

sub CreateEnemyTileSelection()
    local ButtonGrid, temp
    dim Buttons_Enemy

    ButtonGrid = ButtonCreateGrid(BUTTON_SIZE * 12, BOARD_SIZE_Y * (BUTTON_SIZE + 4), BUTTON_SIZE * (12 + NUMBER_OF_ENEMIES), BOARD_SIZE_Y * (BUTTON_SIZE + 6), NUMBER_OF_ENEMIES, 1)
    temp = ButtonCreateByGrid(ButtonGrid, 1, 1, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Enemy.TileEnemy1]
    temp.DebounceTime = 500    
    ButtonShow(temp)
    Buttons_Enemy << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 2, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[Enemy.TileEnemy2]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Enemy << temp
end

sub CreateLevelExitTileSelection()
    local ButtonGrid, temp
    dim Buttons_Exit
     
    ButtonGrid = ButtonCreateGrid((BUTTON_SIZE * 4), BOARD_SIZE_Y * (BUTTON_SIZE + 4), 2*BUTTON_SIZE * NUMBER_OF_EXIT, BOARD_SIZE_Y * (BUTTON_SIZE + 6), NUMBER_OF_EXIT, 1)
    temp = ButtonCreateByGrid(ButtonGrid, 1, 1, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[LevelExit.TileUp]
    temp.DebounceTime = 500    
    ButtonShow(temp)
    Buttons_Exit << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 2, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[LevelExit.TileDown]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Exit << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 3, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[LevelExit.TileLeft]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Exit << temp

    temp = ButtonCreateByGrid(ButtonGrid, 1, 4, 0, "")
    temp.LineColor = rgb(100,100,100)
    temp.Img = Tiles[LevelExit.TileRight]
    temp.DebounceTime = 500
    ButtonShow(temp)
    Buttons_Exit << temp
end

sub CreateAllTileSelection()
    local NumberOfLines, ii, ButtonGrid, xx, yy, temp, 
    dim Buttons_AllTiles

    NumberOfLines = ubound(Tiles)
    ii = 1
    ButtonGrid  = ButtonCreateGrid(0, YMAX - TILES_BG_Y * BUTTON_SIZE, TILES_BG_X * BUTTON_SIZE, YMAX, TILES_BG_X, TILES_BG_Y)

    for yy = 1 to TILES_BG_Y
      for xx = 1 to TILES_BG_X
        
        temp = ButtonCreateByGrid(ButtonGrid, yy, xx, 0, "")
        temp.Img = Tiles[ii]
        temp.LineColor = rgb(100,100,100)
        temp.DebounceTime = 500
        ButtonShow(temp)
        Buttons_AllTiles << temp
        
        ii++
        if(ii > NumberOfLines)
            ' exit both for loops
            xx = TILES_BG_X  
            yy = TILES_BG_Y
        endif
      next
    next
    
    Buttons_AllTiles[1].LineColor = rgb(255,255,255)
    ButtonShow(Buttons_AllTiles[1])
end

sub DrawBoard()
    local yy, xx, index, im, t, posx, posy

    for yy = 1 to BOARD_SIZE_Y
        for xx = 1 to BOARD_SIZE_X
            
            index = (yy - 1) * BOARD_SIZE_X + xx
            posx = (xx-1) * BUTTON_SIZE
            posy = (yy-1) * BUTTON_SIZE
            
            t = Board[index].BG_Tile  
            if(t) 
                im = Tiles[t]
                im.draw(posx,posy)                
            endif
            t = Board[index].Bonus_Tile            
            if(t)
                im = Tiles[t]
                im.draw(posx,posy)                
            endif
            t = Board[index].Exit_Tile            
            if(t) 
                im = Tiles[t]
                im.draw(posx,posy)                
            endif
            t = Board[index].Enemy_Tile            
            if(t)
                im = Tiles[t]
                im.draw(posx,posy)                
            endif
            t = Board[index].Trap            
            if(t)
                rect posx + BUTTON_SIZE/2 - 6,posy + BUTTON_SIZE/2 - 3 step 6,6, COLOR_RED filled                
            endif
            t = Board[index].Block            
            if(t)
                rect posx + BUTTON_SIZE/2 ,posy + BUTTON_SIZE/2 - 3 step 6,6, COLOR_GREEN filled                
            endif
            
        next
    next
    im = Tiles[Player.Tile]
    im.draw((Player.PositionX - 1) * BUTTON_SIZE, (Player.PositionY - 1) * BUTTON_SIZE)
end

sub CreateBoard()
    local ButtonGrid, yy, xx, temp, temp1
    dim Board
    dim BoardButtons

    ButtonGrid = ButtonCreateGrid(0, 0, BOARD_SIZE_X * BUTTON_SIZE, BOARD_SIZE_Y * BUTTON_SIZE, BOARD_SIZE_X, BOARD_SIZE_Y)
    for yy = 1 to BOARD_SIZE_Y
        for xx = 1 to BOARD_SIZE_X
            temp = ButtonCreateByGrid(ButtonGrid, yy, xx, 0, "")
            temp.LineColor = rgb(100,100,100)
            temp.DebounceTime = 500
            'temp.Img = Tiles[ZeroTile]
            ButtonShow(temp)        
            BoardButtons << temp
            
            temp1.BG_Tile = ZeroTile
            temp1.Bonus_Tile = 0
            temp1.Bonus_Name = 0
            temp1.Exit_Tile = 0
            temp1.Trap = 0
            temp1.Enemy_Tile = 0
            temp1.Enemy_Name = 0
            temp1.Block = 1
            Board << temp1
        next
    next    
    
end


sub LoadTiles()
    local TileSet, temp, NumberOfLines, xx, yy, ii
    dim Tiles
    
    LOGPRINT TILE_SET_FILE
    tload PATH_TO_DATA + TILE_SET_FILE, TileSet
    NumberOfLines = ubound(TileSet)
    ii++
    temp = array(TileSet[ii])
    Player.TileUp = temp.Player_up
    Player.TileDown = temp.Player_down
    Player.TileLeft = temp.Player_left
    Player.TileRight = temp.Player_right
    ii++
    temp = array(TileSet[ii])
    Bonus.TileBonus1 = temp.Bonus_1
    Bonus.TileBonus2 = temp.Bonus_2
    Bonus.TileBonus3 = temp.Bonus_3
    Bonus.TileBonusLive = temp.Bonus_live
    ii++
    temp = array(TileSet[ii])
    LevelExit.TileUp = temp.Exit_up
    LevelExit.TileDown = temp.Exit_down
    LevelExit.TileLeft = temp.Exit_left
    LevelExit.TileRight = temp.Exit_right
    ii++
    temp = array(TileSet[ii])    
    Enemy.TileEnemy1 = temp.Enemy1
    Enemy.TileEnemy2 = temp.Enemy2
    ii++
    temp = array(TileSet[ii])
    ZeroTile = temp.Zero
        
    while(ii < NumberOfLines)
        ii++
        temp = array(TileSet[ii])
        Tiles << image(PATH_TO_DATA + temp.Tile)
        'LOGPRINT temp
    wend
    
end


func FileSelectDialog(Type, x, y, w, h, ButtonSize)
' Displays a file select dialog. If type is 0 (LOAD) then the function
' will always return a existing file. If type is 1 (SAVE) the returned
' file might exist. If user cancel the file dialog, the function will
' return -1
'
' Type        : 0 = Load; 1 = Save
' x,y         : position on screen in pixel
' w,h         : width and height in pixel
' ButtonSize  : size of the buttons in pixel, 0 = auto
' Return value: file selected by user

    local listbox, textbox, buttons, f, GUI, ReturnValue = 0, win
    local GetFileList, cmpfunc_strings, index, Directory, FileList
    local BGColor, TextColor, ElementColor, GraphicCursor, ii
    
    BGColor = rgb(100, 100, 100)
    TextColor = rgb(255, 255, 255)
    ElementColor = rgb(80, 80, 80)
    
    x = x + 2
    y = y + 2
    w = w - 4
    h = h - 6

    win = window()
    win.graphicsScreen2()
    color 15,0
    cls
    color TextColor, BGColor
    
    Directory = cwd()
    
    if(ButtonSize == 0) then ButtonSize = 3 * Textwidth("W")    
    
    func cmpfunc_strings(x, y)
        x = lower(x)
        y = lower(y)
        
        if x == y
            return 0
        elseif x > y
            return 1
        else
            return -1
        endif
    end
    
    func GetFileList()
        local FileList
        FileList = files("*")
        
        if(len(FileList) > 0)
            for ii = 1 to ubound(FileList)            
                if(isdir(FileList[ii])) then FileList[ii] = enclose(FileList[ii], "[]")                
            next 
            sort FileList use cmpfunc_strings(x, y)        
            insert FileList, 1, "[..]"
        else
            FileList = "[..]"
        endif
             
        return FileList
    end    

    listbox.type = "listbox"
    listbox.x = x
    listbox.y = y + 2*ButtonSize
    listbox.height = h - 3.5 * ButtonSize
    listbox.width = w - ButtonSize
    listbox.color = TextColor
    listbox.backgroundColor = ElementColor
    listbox.value = GetFileList()
    listbox.selectedIndex = -1
    listbox.length = ubound(listbox.value) - 1
    listbox.noFocus = 1
    f.inputs << listbox
    
    textbox.type = "text"
    textbox.x = x
    textbox.y = y + ButtonSize
    textbox.width = w - ButtonSize
    textbox.value = cwd
    textbox.color = TextColor
    textbox.backgroundColor = ElementColor
    textbox.length = 500 ' number of characters
    textbox.noFocus = 0
    f.inputs << textbox
    
    buttons.type = "button"
    buttons.x = x + w - ButtonSize
    buttons.y = y + 2*ButtonSize
    buttons.width = ButtonSize
    buttons.height = ButtonSize
    buttons.label = "/\\"
    buttons.backgroundcolor = ElementColor
    buttons.color = TextColor
    buttons.noFocus = 1
    f.inputs << buttons

    buttons.type = "button"
    buttons.x = x + w - ButtonSize
    buttons.y = y + h - 2.5*ButtonSize
    buttons.width = ButtonSize
    buttons.height = ButtonSize
    buttons.label = "\\/"
    buttons.backgroundcolor = ElementColor
    buttons.color = TextColor
    buttons.noFocus = 1
    f.inputs << buttons

    buttons.type = "button"
    buttons.x = x + w - 6.5 * ButtonSize
    buttons.y = y + h - ButtonSize
    buttons.width = ButtonSize * 3
    buttons.height = ButtonSize
    buttons.label = "SELECT"
    buttons.backgroundcolor = ElementColor
    buttons.color = TextColor
    buttons.noFocus = 1
    f.inputs << buttons

    buttons.type = "button"
    buttons.x = x + w - 3 * ButtonSize
    buttons.y = y + h - ButtonSize
    buttons.width = ButtonSize * 3
    buttons.height = ButtonSize
    buttons.label = "CANCEL"
    buttons.backgroundcolor = ElementColor
    buttons.color = TextColor
    buttons.noFocus = 1
    f.inputs << buttons    
    
    rect x - 2, y - 2 STEP w + 4, h + 6 color BGColor filled
    at x,y
    if(Type == 0)
        print "LOAD FILE:"
    else
        print "SAVE FILE:"
    endif
    
    GUI = form(f)
        
    while(ReturnValue == 0)
      GUI.doEvents()
      
      ' Check for value of the active input field
      if (len(GUI.value) > 0) then

        select case GUI.value
            case "/\\"
                if(GUI.inputs[1].selectedIndex > 0)
                    GUI.inputs[1].selectedIndex = GUI.inputs[1].selectedIndex - 1
                    index = GUI.inputs[1].selectedIndex + 1
                    
                    f = disclose(GUI.inputs[1].value[index], "[]")
                    if(f != "")         ' directory                  
                        GUI.inputs[2].value = cwd + f
                    else                ' file
                        GUI.inputs[2].value = cwd + GUI.inputs[1].value[index]
                    endif
                    
                    GUI.refresh(0)
                endif
            case "\\/"
                if(GUI.inputs[1].selectedIndex < GUI.inputs[1].length)
                    GUI.inputs[1].selectedIndex = GUI.inputs[1].selectedIndex + 1
                    
                    index = GUI.inputs[1].selectedIndex + 1
                    f = disclose(GUI.inputs[1].value[index], "[]")
                    
                    if(f != "")         ' directory                  
                        GUI.inputs[2].value = cwd + f
                    else                ' file
                        GUI.inputs[2].value = cwd + GUI.inputs[1].value[index]
                    endif
                    
                    GUI.refresh(0)
                endif
            case "SELECT"
                if(isdir(GUI.inputs[2].value))
                    chdir(GUI.inputs[2].value)
                    GUI.inputs[1].value = GetFileList()
                    GUI.refresh(0)
                elseif(isfile(GUI.inputs[2].value))
                    ReturnValue = GUI.inputs[2].value
                elseif(Type == 1)                     ' if Save
                    ReturnValue = GUI.inputs[2].value
                else
                    win.alert("Not a valid file or directory")
                endif
            case "CANCEL"
                ReturnValue = -1
            case else   ' user clicked on a file in the file listbox
                f = disclose(GUI.value, "[]")
                if(f != "") then 
                    chdir f
                    GUI.inputs[1].value = GetFileList()
                    GUI.inputs[2].value = cwd
                    GUI.refresh(0)
                else
                    index = GUI.inputs[1].selectedIndex + 1
                    GUI.inputs[2].value = cwd + GUI.inputs[1].value[index]
                    GUI.refresh(0)
                endif
                    
        end select
        
      endif
        
    wend

    GUI.close()
    
    'chdir Directory
    win.graphicsScreen1()
    
    return ReturnValue

end


'Buttons #####################################################################

func ButtonCreateGrid(x1, y1, x2, y2, nx, ny)
    local x,xx,y,yy, Grid
    
    dim Grid(nx + 1, ny + 1)
    
    x = seq(x1, x2, nx + 1)
    y = seq(y1, y2, ny + 1)
    
    for yy = 1 to ny + 1
        for xx = 1 to nx + 1
            Grid[xx,yy] = [ x[xx], y[yy] ]
        next
    next
    
    return Grid
    
end

func ButtonCreateByGrid(Grid, row, coll, Padding, s)
    local B,x,y,w,h
    
    x = Grid[coll, row][1] + Padding
    y = Grid[coll, row][2] + Padding
    w = Grid[coll + 1, row][1] - x - Padding
    h = Grid[coll, row + 1][2] - y - Padding
        
    return ButtonCreate(x,y,w,h,s)
end

func ButtonCreate(x,y,w,h,s)
    local B
    
    ' Properties
    B.x = x
    B.y = y
    B.h = h
    B.w = w
    B.text = s
    B.DebounceTime = 60
    B.DebounceTimer = ticks()
    B.LastState = false
    B.FillColor = 8
    B.LineColor = 15
    B.TextColor = 15 
    B.Img = 0
    B.hidden = false
    
    return B    
end

sub ButtonShow(byref B)
    local temp

    if(B.hidden) then exit
    if(!B.Img) then
        rect B.x, B.y, step B.w, B.h, B.FillColor filled
        rect B.x, B.y, step B.w, B.h, B.LineColor
        at B.x + (B.w - Textwidth(B.text))/2, B.y + (B.h - TextHeight(B.text))/2
        color B.TextColor, B.FillColor
        print B.text
    else
        temp = B.Img
        temp.draw(B.x, B.y)
        rect B.x, B.y, step B.w, B.h, B.LineColor
    endif   
end


    
func ButtonIsPressed(byref B)
  local state = 0
      
  if(ticks() - B.DebounceTimer > B.DebounceTime) then
    if(pen(4) > B.x AND pen(4) < B.x + B.w AND pen(5) > B.y AND pen(5) < B.y + B.h)
      state = 1
      B.DebounceTimer = ticks()
    endif 
            
    if(B.LastState != state) then
      B.DebounceTimer = 0
      B.LastState = state
    endif
  else
    state = B.LastState
  endif

  return state
end
    
func ButtonIsPressedAgain(byref B)
  local state
  state = 0
                
  if(pen(4) > B.x AND pen(4) < B.x + B.w AND pen(5) > B.y AND pen(5) < B.y + B.h)
    if(ticks() - B.DebounceTimer > B.DebounceTime) then
      state = 1
    endif 
               
    B.DebounceTimer = ticks()  
    
    B.LastState = state
            
  endif

  return state

end


