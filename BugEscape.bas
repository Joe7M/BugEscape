option base 1

import raylib as rl
'import raylibc as c

dim c
c.BLACK = [0, 0, 0]
c.WHITE = [255, 255, 255]
c.KEY_Q = 81
c.KEY_ESCAPE = 256
c.KEY_SPACE = 32
c.KEY_ENTER = 257
c.KEY_DOWN = 264
c.KEY_UP = 265
c.KEY_LEFT = 263
c.KEY_RIGHT = 262

PATH_TO_SETTINGS = "./"
if(instr(sbver, "Win"))
    PATH_TO_SETTINGS = home() + "\\AppData\\Roaming\\SmallBASIC\\BugEscape\\"
elseif(instr(sbver, "Unix"))
    PATH_TO_SETTINGS = home() + "/.config/SmallBASIC/BugEscape/"
endif

const PATH_TO_DATA = "./DATA/"

try
    tload PATH_TO_SETTINGS + "SETTINGS.DAT", Settings
    Settings = array(Settings[1])
catch
    Settings = {MusicVolume:10, SoundVolume:10, Fullscreen:"OFF", WindowScale:1}
    
    if(instr(sbver, "Win"))
       if(!isdir(home() + "\\AppData\\Roaming\\SmallBASIC")) then mkdir(home() + "\\AppData\\Roaming\\SmallBASIC")
    elseif(instr(sbver, "Unix"))
       if(!isdir(home() + "/.config/SmallBASIC")) then mkdir(home() + "/.config/SmallBASIC")
    endif
        
    if(!isdir(PATH_TO_SETTINGS)) then mkdir(PATH_TO_SETTINGS)
    tsave(PATH_TO_SETTINGS + "SETTINGS.DAT", Settings)
end try
'Settings = {MusicVolume:10, SoundVolume:10, Fullscreen:"OFF", WindowScale:1}

      TILE_SIZE                 = 32 * Settings.WindowScale
      TILE_SCALE                = Settings.WindowScale
const BOARD_SIZE_X              = 30
const BOARD_SIZE_Y              = 15
      SCREEN_X = BOARD_SIZE_X * TILE_SIZE
      SCREEN_Y = BOARD_SIZE_Y * (TILE_SIZE + 2*TILE_SCALE)
const NUMBER_OF_BONUSES         = 4
const NUMBER_OF_EXIT            = 4
const ANIMATION_TIME            = 0.2  ' seconds
const PLAYER_SPEED              = 2
const ENEMY_SPEED               = 20
const COLORS = [[36,38,114], [43,89,183], [53,174,235], [126,213,233], [244,233,233], [249,210,168], [249,184,124], [217,129,72], [141,105,112], [101,78,104], [25,13,20], [57,50,56], [97,99,107], [145,151,157], [196,208,216], [10,52,34], [32,102,36], [63,156,44], [181,206,45], [249,229,84], [253,193,26], [255,117,36], [233,54,43], [148,20,45], [84,14,53], [127,54,135], [189,85,150], [255,130,124], [249,170,139], [170,74,38], [116,27,11], [72,14,4]]
  '    SCORE_HEIGHT              = TILE_SIZE
const BONUS_SCORE_1 = 10
const BONUS_SCORE_2 = 20
const BONUS_STEPS = 20
const GAMESTATE_LEVEL_IS_RUNNING              = 1
const GAMESTATE_PLAYER_IS_DEAD                = 2
const GAMESTATE_MENU                          = 3
const GAMESTATE_NEXT_LEVEL                    = 4
const GAMESTATE_QUIT_GAME                     = 5
const GAMESTATE_PLAYER_WILL_DIE_ANIMATION     = 6
const GAMESTATE_PLAYER_IS_MOVING              = 7
const GAMESTATE_PLAYER_DIED                   = 8
const GAMESTATE_GAME_OVER                     = 9
const GAMESTATE_PLAYER_COLLECT_BONUS          = 10
const GAMESTATE_PLAYER_AT_EXIT                = 11
const GAMESTATE_LEVEL_FINISHED                = 12
const GAMESTATE_CREDITS                       = 13
const GAMESTATE_SETTINGS                      = 14
const GAMESTATE_GAME_FINISHED                 = 15
const GAMESTATE_INTRO                         = 16
const GAMESTATE_USERFILE                      = 17
const GAMESTATE_TOGGLE_FLAG                   = 18

GameState = GAMESTATE_INTRO

dim Board
dim Tiles
dim LettersBug
dim LettersEscape
dim Bug
dim MenuBG
dim Enemies
dim Sounds
dim Music

Player       = {PositionX:1,PositionY:1, StartPosition: [0,0], Tile: 1, StartTile:1, TileUp:1, TileDown:1, TileLeft:1, TileRight:1, PlayerMoving:{x:0, y:0, s:0}, Footsteps:0, Lives: 3, Score: 0, Steps:0, TileFlag: 0, FlagPosition: 1}
Bonus        = {TileBonus1:1, TileBonus2:1, TileBonus3:1, TileBonusLive:1}
LevelExit    = {TileUp:1, TileDown:1, TileLeft:1, TileRight:1}
Enemy        = {TileEnemy1:1, TileEnemy2:1}
ZeroTile     = 0
TrapCounter = 0
DeltaTime = 0.1
UserLevelPath = home()
UserLevelFile = 0
NumberOfEnemies = 0
MusicPlaying = true

' Init raylib
rl.InitWindow(SCREEN_X, SCREEN_Y, "Bug Escape")
if(Settings.Fullscreen == "ON")
    SetFullScreen()
endif

rl.SetTargetFPS(60)
rl.HideCursor()
rl.SetExitKey(c.KEY_Q)
rl.InitAudioDevice()
LoadSounds()
LoadMusic()

Font = rl.LoadFontEx(PATH_TO_DATA + "FONTS/GravityBold8.ttf", 8, 250)  ' Change to 512
LoadGUIImages()


tload PATH_TO_DATA + "LEVELS/LIST.TXT", LevelList
Print LevelList
CurrentLevel = 1
MaxLevel = ubound(LevelList)

' Load level from command line
' sbasic bugescape.bas level.lvl
if(Command != "")
    ' Check for -m ./ and remove it
    if(left(Command, 5,) == "-m ./")
        Parameter = mid(Command, 7)
    else
        Parameter = Command
    endif
    
    ' What kind of parameter: user-level or level-list?    
    if(right(Parameter,3) == "LVL")
        If(!IsFile(Parameter)) then throw("File not found")
        UserLevelFile = Parameter
        LoadLevel(UserLevelFile, TRUE)
        GameState = GAMESTATE_LEVEL_IS_RUNNING
    elseif(right(Parameter,3) == "TXT")
        If(!IsFile(Parameter)) then throw("File not found")
        tload Parameter, LevelList
        CurrentLevel = 1
        MaxLevel = ubound(LevelList)
        LoadLevel(LevelList[1], FALSE)
        GameState = GAMESTATE_LEVEL_IS_RUNNING
    endif
endif


while(GameState != GAMESTATE_QUIT_GAME AND !rl.WindowShouldClose())
       
    select case GameState
        case GAMESTATE_INTRO
            DoIntro()
        case GAMESTATE_MENU
            DoMenu()
        case GAMESTATE_USERFILE
            DoUserFile()
        case GAMESTATE_SETTINGS
            DoSettings()
        case GAMESTATE_HIGHSCORE
            DoHighscore()
        case GAMESTATE_CREDITS
            DoCredits()
        case GAMESTATE_LEVEL_IS_RUNNING
            DoGameLoop()
        case GAMESTATE_LEVEL_FINISHED
            DoScoreUpdate()
            if(UserLevelFile != 0)
                GameState = GAMESTATE_USERFILE
            else
                CurrentLevel++
                NewLevel()                
            endif
        case GAMESTATE_GAME_OVER
            if(DoGameOver() == 1)       ' Restart Level
                Player.Lives = 3
                Player.Score = 0
                Player.Steps = 0
                NewLevel()
                UpdateTrapCounter()
            else
                if(UserLevelFile != 0)
                    GameState = GAMESTATE_USERFILE
                else
                    DoHighscore()
                    GameState = GAMESTATE_MENU
                endif
            endif
        case GAMESTATE_GAME_FINISHED
            DoEndOfFun()
            DoHighscore()
            Gamestate = GAMESTATE_MENU
    end select
wend

UnloadTextures()
UnloadSounds()
UnloadMusic()
rl.CloseWindow()


'#############################################
sub EnemyHitPlayer() 
    for ii = 1 to NumberOfEnemies
        if(Enemies[ii].x = Player.PositionX AND Enemies[ii].y = Player.PositionY)
            GameState = GAMESTATE_PLAYER_WILL_DIE_ANIMATION
        endif
    next
end


sub DrawEnemies()    
    for ii = 1 to NumberOfEnemies
        
        Enemies[ii].MovingVector.s = Enemies[ii].MovingVector.s - DeltaTime * ENEMY_SPEED * TILE_SCALE
        if(Enemies[ii].MovingVector.s <= 0)
            Enemies[ii].x = Enemies[ii].x - Enemies[ii].MovingVector.x
            Enemies[ii].y = Enemies[ii].y - Enemies[ii].MovingVector.y
            
            bb = GetBoardIndex(Enemies[ii].x, Enemies[ii].y)
            if(bb < 0 OR Board[bb].Block)
                Enemies[ii].MovingVector.x = -Enemies[ii].MovingVector.x
                Enemies[ii].MovingVector.y = -Enemies[ii].MovingVector.y
                Enemies[ii].x = Enemies[ii].x - 2*Enemies[ii].MovingVector.x
                Enemies[ii].y = Enemies[ii].y - 2*Enemies[ii].MovingVector.y
            endif
            Enemies[ii].MovingVector.s = TILE_SIZE
        endif        
        
        tile = Tiles[Enemies[ii].Enemy_Tile]
        pos.x = (Enemies[ii].x - 1) * TILE_SIZE
        pos.y = Enemies[ii].y * TILE_SIZE  ' SCORE_HEIGHT
        pos.x = pos.x + Enemies[ii].MovingVector.x * Enemies[ii].MovingVector.s
        pos.y = pos.y + Enemies[ii].MovingVector.y * Enemies[ii].MovingVector.s
        'rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
        if(Enemies[ii].MovingVector.x < 0 OR Enemies[ii].MovingVector.y < 0 )
            rl.DrawTexturePro(tile.Texture, [0,0,-31,31], [pos.x,pos.y, 31*TILE_SCALE, 31*TILE_SCALE], [0,0], 0, c.WHITE)
        else
            rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
        endif
        
        if(AnimationTimer == ANIMATION_TIME) then Enemies[ii].Enemy_Tile = tile.next
    next
end


sub DoEndOfFun()
    local AnimationTimer, x, y, col, KeyPressed = 0, TextString
        
    TextString = "CONGRATULATIONS! YOU REACHED THE END OF THE WORLD. THANK YOU FOR PLAYING BUG ESCAPE. MAYBE IT IS TIME TO CREATE YOUR OWN WORLD. SMALLBASIC (SMALLBASIC.GITHUB.IO) WILL BE A GREAT STARTING POINT."
    x = SCREEN_X
    y = SCREEN_Y/2 - TILE_SIZE
    col = 1  
    
    rl.PollInputEvents()
      
    Repeat
        if(rl.IsKeyPressed(c.KEY_ESCAPE) OR rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER)) then
                KeyPressed = 1
        endif
          
        x = x - 200 * DeltaTime
        
        if(x < -5100) then x = SCREEN_X
        
        if(AnimationTimer > 0.1)
            AnimationTimer = 0
            col++
            if(col == 11) then col = 16
            if(col > 32) then col = 1
        endif
        
            
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)
            rl.DrawTextEx(Font, TextString, [x, y], TILE_SIZE, 2, Colors[col])
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer += DeltaTime
      
           
    Until(KeyPressed)
end


sub NewLevel()
    if(UserLevelFile != 0) ' UserLevel
        GameState = GAMESTATE_LEVEL_IS_RUNNING
        LoadLevel(UserLevelFile, TRUE)
    elseif(CurrentLevel > MaxLevel)
        GameState = GAMESTATE_GAME_FINISHED
    else
        LoadLevel(LevelList[CurrentLevel], FALSE)
        GameState = GAMESTATE_LEVEL_IS_RUNNING
    endif
end


sub DoUserFile()
    local f, FileList, temp, ii, ListPosition, AppPath, FileListLength, ListOffset, MaxFiles
    const MAXFILES = 25
    
    AppPath = cwd
    chdir(UserLevelPath)
        
    local func GetFileList()
        local AllFiles, FileList, f
        dim FileList
        
        AllFiles = Files("*")
        sort AllFiles    
    
        temp.file = ".."
        temp.type = "D"
        FileList << temp
        
        for f in AllFiles
            if(left(f, 1) != ".")
                if(isdir(f)) then
                    temp.file = f
                    temp.type = "D"
                    FileList << temp 
                else
                    'if(right(f,3) == "LVL" or right(f,3) == "lvl")
                        temp.file = f
                        temp.type = "F"
                        FileList << temp
                    'endif
                endif
            endif
        next           
         
        return FileList            
    end
    
    ListPosition = 1
    ListOffset = 0
        
    FileList = GetFileList()
    FileListLength = ubound(FileList)
    
    rl.PollInputEvents()           ' Call for update keys, otherwise SB dosen't
                                   ' realize, that RETURN is not pressed anymore

    Repeat
      
        if(rl.IsKeyPressed(c.KEY_ESCAPE)) then
                Gamestate = GAMESTATE_MENU
        endif
        if(rl.WindowShouldClose()) then Gamestate = GAMESTATE_QUIT_GAME
        
        if(rl.IsKeyPressed(c.KEY_DOWN))
            if(ListPosition < len(FileList)) then ListPosition++            
            ListOffset = (MaxFiles - 1) * (ListPosition \ MAXFILES)
            rl.PlaySound(Sounds.Ping)
        endif
        if(rl.IsKeyPressed(c.KEY_UP))
            if(ListPosition > 1) then ListPosition--
            ListOffset = (MaxFiles - 1) * (ListPosition \ MAXFILES)
            rl.PlaySound(Sounds.Ping)            
        endif
        
        if(rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER))
            rl.PlaySound(Sounds.Ping)
            if(FileList[ListPosition].type == "D")
                chdir(FileList[ListPosition].file)
                FileList = GetFileList()
                ListPosition = 1
                FileListLength = ubound(FileList)
                ListOffset = 0
            endif
            if(FileList[ListPosition].type == "F")
                UserLevelPath = cwd()
                chdir(AppPath)
                UserLevelFile = UserLevelPath + FileList[ListPosition].file
                LoadLevel(UserLevelFile, TRUE)
                GameState = GAMESTATE_LEVEL_IS_RUNNING                
            endif
            
        endif
        
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            
            
            ii = 0
            while(ii < MAXFILES)
                ii++
                
                if(ii + ListOffset > FileListLength) then exit
                
                f = FileList[ii + ListOffset]
                
                if(f.type == "D") then 
                    rl.DrawTextEx(Font, "[" + f.file + "]"  , [TILE_SIZE*11, TILE_SIZE/2 * (ii + 2)], 0.4 * TILE_SIZE, 2, Colors[27])
                else
                    rl.DrawTextEx(Font, f.file, [TILE_SIZE*11, TILE_SIZE/2 * (ii + 2)], 0.4 * TILE_SIZE, 2, Colors[26])
                endif
            wend
            rl.DrawTextEx(Font, ">>"  , [TILE_SIZE*10, TILE_SIZE/2 * (ListPosition - ListOffset + 2)], 0.4 * TILE_SIZE, 2, Colors[27])
            
            
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer += DeltaTime
        UpdateMusic()
           
    Until(Gamestate != GAMESTATE_USERFILE)
    
   
    chdir AppPath
    
end

sub DoIntro()
    local AnimationTimer, IntroImage, HelpImage, x, y, TempMusicVolume, KeyPressed = false
        
    IntroImage = rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/IntroImage.png")
    HelpImage = rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/Help.png")
    
    TempMusicVolume = Settings.MusicVolume
    Settings.MusicVolume = 10
    MusicPlaying = true
    rl.SetMusicVolume(Music.Tracks[Music.CurrentTrack], 0.25)    
    
    Repeat
        if(rl.IsKeyPressed(c.KEY_ESCAPE) OR rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER)) then                
                KeyPressed = true
        endif
        if(rl.WindowShouldClose()) then Gamestate = GAMESTATE_QUIT_GAME
            
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            
            rl.DrawTextEx(Font, "    J7M"  , [TILE_SIZE*11, TILE_SIZE*2], TILE_SIZE, 2, Colors[27])
            rl.DrawTextEx(Font, "   PRESENTS", [TILE_SIZE*12.2, TILE_SIZE*3.5], 0.5*TILE_SIZE, 2, Colors[26])
            
            
            if(AnimationTimer > 0.5)  ' BUG text from left side
                x = 1000*(AnimationTimer - 0.5)
                if(x > TILE_SIZE*5.5) then x = TILE_SIZE * 5.5
                
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3) 
                rl.DrawTextureEx(LettersBug[1], [x, y], 0, TILE_SCALE, c.WHITE)
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+2*pi/9)
                rl.DrawTextureEx(LettersBug[2], [x + 2*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+4*pi/9)      
                rl.DrawTextureEx(LettersBug[3], [x + 4*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)        
            endif
            if(AnimationTimer > 1.5)  ' TRAP text from left side
                x = SCREEN_X + 2*TILE_SIZE - 1000*(AnimationTimer - 1.5)
                if(x < TILE_SIZE*12.5) then x = TILE_SIZE * 12.5
                
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+6*pi/9)   
                rl.DrawTextureEx(LettersEscape[1], [x, y], 0, TILE_SCALE, c.WHITE)
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+8*pi/9)  
                rl.DrawTextureEx(LettersEscape[2], [x + 2*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)  
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+10*pi/9)
                rl.DrawTextureEx(LettersEscape[3], [x + 4*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)                
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+12*pi/9)  
                rl.DrawTextureEx(LettersEscape[4], [x + 6*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+14*pi/9) 
                rl.DrawTextureEx(LettersEscape[5], [x + 8*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
                y = 5*TILE_SIZE + 0.25*TILE_SIZE*sin(AnimationTimer*3+16*pi/9)  
                rl.DrawTextureEx(LettersEscape[6], [x + 10*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)         
            endif
            if(AnimationTimer > 3)  ' Intro image
                rl.DrawTextureEx(IntroImage, [TILE_SIZE * 12, TILE_SIZE * 8], 0, TILE_SCALE, c.WHITE)  
            endif
            if(AnimationTimer > 4)
                if( ((AnimationTimer*100) % 10) > 5)
                    rl.DrawTextEx(Font, ">> PRESS BUTTON << ",  [TILE_SIZE * 11, TILE_SIZE * 15], TILE_SIZE/2, 2, COLORS[23])
                endif
            endif
            
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer += DeltaTime
        
        UpdateMusic()
        
    Until(KeyPressed)
    
    KeyPressed = false
    AnimationTimer = 0
    
    Repeat
        if(rl.IsKeyPressed(c.KEY_ESCAPE) OR rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER))
                KeyPressed = true
        endif
        if(rl.WindowShouldClose()) then Gamestate = GAMESTATE_QUIT_GAME
            
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            
            rl.DrawTextureEx(HelpImage, [TILE_SIZE * 5, TILE_SIZE*0.5], 0, TILE_SCALE, c.WHITE) 
            
            if(AnimationTimer > 0.5)
                rl.DrawTextEx(Font, "FIND YOUR WAY BACK HOME", [TILE_SIZE*11, TILE_SIZE*0.7], TILE_SIZE/2, 2, Colors[3])
            endif
            if(AnimationTimer > 1)
                rl.DrawTextEx(Font, "AND AVOID HIDDEN TRAPS", [TILE_SIZE*11, TILE_SIZE*1.7], TILE_SIZE/2, 2, Colors[3])
            endif
            if(AnimationTimer > 1.5)
                rl.DrawTextEx(Font, "USE ARROW KEYS OR D-PAD", [TILE_SIZE*11, TILE_SIZE*2.7], TILE_SIZE/2, 2, Colors[3])
            endif
            if(AnimationTimer > 2.5)
                rl.DrawTextEx(Font, "USE YOUR SIXTH SENSE", [TILE_SIZE*11, TILE_SIZE*4.7], TILE_SIZE/2, 2, Colors[4])
            endif
            if(AnimationTimer > 3)
                rl.DrawTextEx(Font, "TO FEEL THE TRAPS", [TILE_SIZE*11, TILE_SIZE*5.7], TILE_SIZE/2, 2, Colors[4])
            endif
            if(AnimationTimer > 4)
                rl.DrawTextEx(Font, "PRESS SPACE OR FIRE TO", [TILE_SIZE*11, TILE_SIZE*7.7], TILE_SIZE/2, 2, Colors[6])
            endif    
            if(AnimationTimer > 4.5)
                rl.DrawTextEx(Font, "PLACE OR REMOVE A LITTLE REMINDER ", [TILE_SIZE*11, TILE_SIZE*8.7], TILE_SIZE/2, 2, Colors[6])
            endif        
            if(AnimationTimer > 5.5)
                rl.DrawTextEx(Font, "10 POINTS", [TILE_SIZE*11, TILE_SIZE*10.7], TILE_SIZE/2, 2, Colors[20])
            endif
            if(AnimationTimer > 6.0)
                rl.DrawTextEx(Font, "20 POINTS", [TILE_SIZE*11, TILE_SIZE*11.7], TILE_SIZE/2, 2, Colors[23])
            endif
            if(AnimationTimer > 6.5)
                rl.DrawTextEx(Font, "20 STEPS", [TILE_SIZE*11, TILE_SIZE*12.7], TILE_SIZE/2, 2, Colors[27])
            endif
            if(AnimationTimer > 7)
                rl.DrawTextEx(Font, "EXTRA LIVE", [TILE_SIZE*11, TILE_SIZE*13.7], TILE_SIZE/2, 2, Colors[28])
            endif
            
            if(AnimationTimer > 9)
                if( ((AnimationTimer*100) % 10) > 5)
                    rl.DrawTextEx(Font, ">> PRESS BUTTON << ",  [TILE_SIZE * 11, TILE_SIZE * 15], TILE_SIZE/2, 2, COLORS[23])
                endif
            endif
            
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer += DeltaTime
        
        UpdateMusic()
        
    Until(KeyPressed)
    
    Gamestate = GAMESTATE_MENU
    rl.UnloadTexture(IntroImage)
    rl.UnloadTexture(HelpImage)
    Settings.MusicVolume = TempMusicVolume
    rl.SetMusicVolume(Music.Tracks[Music.CurrentTrack], Settings.MusicVolume / 10 * 0.25)    
    if(Settings.MusicVolume == 0) then MusicPlaying = false
end

sub LoadGUIImages()
    
    LettersBug << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/B.png")
    LettersBug << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/U.png")
    LettersBug << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/G.png")
    
    LettersEscape << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/E.png")
    LettersEscape << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/S.png")
    LettersEscape << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/C.png")
    LettersEscape << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/A.png")
    LettersEscape << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/P.png")
    LettersEscape << rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/E.png")

    Bug = rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/bug.png")
    
    MenuBG = rl.LoadTexture(PATH_TO_DATA + "GRAPHICS/MenuBG.png")
end

func DoGameOver()
    local KeyPressed = 0, SelectedEntry = 1
    
    Repeat
        if(rl.IsKeyPressed(c.KEY_ESCAPE)) then
            KeyPressed = 1
            SelectedEntry = 2      
        endif
        
        if(rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER))
            KeyPressed = 1
        endif
            
        if(rl.IsKeyPressed(c.KEY_LEFT))
            SelectedEntry = 1
        endif
        if(rl.IsKeyPressed(c.KEY_RIGHT))
            SelectedEntry = 2
        endif
            
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)
            rl.DrawTextEx(Font, "LAST LIFE LOST" , [TILE_SIZE*9, TILE_SIZE*5], TILE_SIZE, 2, Colors[27])
            rl.DrawTextEx(Font, "   GAME OVER"   , [TILE_SIZE*9, TILE_SIZE*7], TILE_SIZE, 2, Colors[26])
            rl.DrawTextEx(Font, "RESTART LEVEL      BACK TO MENU" , [TILE_SIZE*4, TILE_SIZE*10], TILE_SIZE*0.75, 2, Colors[25])
            rl.DrawTextEx(Font, ">>"             , [TILE_SIZE*(2.5 + 12*(SelectedEntry - 1)), TILE_SIZE*(10)], TILE_SIZE*0.75, 2, Colors[25])
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer -= DeltaTime
           
    Until(KeyPressed)
    
    return SelectedEntry
end


sub DoSettings()
    local OffsetX, Size, Selection, SettingsState, SETTINGS_MUSIC_VOLUME, SETTINGS_SOUND_VOLUME, SETTINGS_WINDOW_SIZE, WindowSize 
    OffsetX = TILE_SIZE * 9
    Size = TILE_SIZE/2
    Selection = 1
    SettingsState = 0
    WindowSize = Settings.WindowScale
    const SETTINGS_MUSIC_VOLUME = 1
    const SETTINGS_SOUND_VOLUME = 2
    const SETTINGS_WINDOW_SIZE  = 3
    
    Repeat
        
        if(rl.IsKeyPressed(c.KEY_ESCAPE)) then
            GameState = GAMESTATE_MENU
        endif
        if(rl.WindowShouldClose()) then Gamestate = GAMESTATE_QUIT_GAME
        
        if(rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER))
            select case Selection
                case 1  ' Fullscreen
                    if(Settings.Fullscreen == "ON")
                        Settings.Fullscreen = "OFF"
                        SetWindowScreen()
                        Size = TILE_SIZE/2
                        OffsetX = TILE_SIZE * 10      
                    else
                        Settings.Fullscreen = "ON"
                        SetFullScreen()
                        Size = TILE_SIZE/2
                        OffsetX = TILE_SIZE * 10                              
                    endif
                case 2  ' Music volume
                    if(SettingsState == SETTINGS_MUSIC_VOLUME) 
                        SettingsState = 0
                    else
                        SettingsState = SETTINGS_MUSIC_VOLUME
                    endif
                case 3  ' Sound volume
                    if(SettingsState == SETTINGS_SOUND_VOLUME) 
                        SettingsState = 0
                    else
                        SettingsState = SETTINGS_SOUND_VOLUME
                    endif
                case 4  ' Window size
                    if(Settings.Fullscreen != "ON")
                        if(SettingsState == SETTINGS_WINDOW_SIZE) 
                            SettingsState = 0
                        else
                            SettingsState = SETTINGS_WINDOW_SIZE
                        endif
                    endif
            end select
            rl.PlaySound(Sounds.Ping)
        endif            
        
        if(rl.IsKeyPressed(c.KEY_UP)) then
            select case SettingsState
                case SETTINGS_MUSIC_VOLUME
                    if(Settings.MusicVolume < 10) then Settings.MusicVolume++
                    rl.SetMusicVolume(Music.Tracks[Music.CurrentTrack], Settings.MusicVolume / 10 * 0.25)
                    MusicPlaying = true
                case SETTINGS_SOUND_VOLUME
                    if(Settings.SoundVolume < 10) then Settings.SoundVolume++
                    rl.SetMasterVolume(Settings.SoundVolume / 10)
                case SETTINGS_WINDOW_SIZE
                    if(WindowSize < 5) 
                        WindowSize+=0.1
                        Settings.WindowScale = WindowSize  
                        TILE_SIZE                 = 32 * WindowSize
                        TILE_SCALE                = TILE_SIZE / 32
                        SCREEN_X = BOARD_SIZE_X * TILE_SIZE
                        SCREEN_Y = BOARD_SIZE_Y * (TILE_SIZE + 2) 
                        Size = TILE_SIZE/2
                        OffsetX = TILE_SIZE * 10
                        rl.SetWindowSize(SCREEN_X, SCREEN_Y)                                     
                        'if(Settings.Fullscreen != "ON") then rl.SetWindowSize(SCREEN_X, SCREEN_Y)
                    endif
                case else
                    Selection--
                    if(Selection < 1) then Selection = 4
            end select
            rl.PlaySound(Sounds.Ping)
        endif
        if(rl.IsKeyPressed(c.KEY_DOWN)) then
            select case SettingsState
                case SETTINGS_MUSIC_VOLUME
                    if(Settings.MusicVolume > 0) then Settings.MusicVolume--
                    rl.SetMusicVolume(Music.Tracks[Music.CurrentTrack], Settings.MusicVolume / 10 * 0.25)
                    if(Settings.MusicVolume == 0) then MusicPlaying = false
                case SETTINGS_SOUND_VOLUME
                    if(Settings.SoundVolume > 0) then Settings.SoundVolume--
                    rl.SetMasterVolume(Settings.SoundVolume / 10)
                case SETTINGS_WINDOW_SIZE
                    if(WindowSize > 0.5) 
                        WindowSize-=0.1
                        Settings.WindowScale = WindowSize
                        TILE_SIZE                 = 32 * WindowSize
                        TILE_SCALE                = TILE_SIZE / 32
                        SCREEN_X = BOARD_SIZE_X * TILE_SIZE
                        SCREEN_Y = BOARD_SIZE_Y * (TILE_SIZE + 2) 
                        Size = TILE_SIZE/2
                        OffsetX = TILE_SIZE * 10               
                        rl.SetWindowSize(SCREEN_X, SCREEN_Y)
                    endif
                case else
                    Selection++
                    if(Selection > 4) then Selection = 1
            end select  
            rl.PlaySound(Sounds.Ping)
        endif 
        
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            
            rl.DrawTextEx(Font, "SETTINGS" , [TILE_SIZE*11.5, TILE_SIZE], Size*2, 2, Colors[28])            
            rl.DrawTextEx(Font, "   FULLSCREEN:",     [OffsetX, TILE_SIZE * 5], Size, 2, COLORS[25])
            rl.DrawTextEx(Font, Settings.Fullscreen,  [OffsetX + 9*TILE_SIZE, TILE_SIZE * 5], Size, 2, COLORS[25])
            rl.DrawTextEx(Font, "   MUSIC VOLUME:",   [OffsetX, TILE_SIZE * 6], Size, 2, COLORS[26])
            rl.DrawTextEx(Font, "   MASTER VOLUME:",  [OffsetX, TILE_SIZE * 7], Size, 2, COLORS[27])
            rl.DrawTextEx(Font, "   WINDOW SIZE:",    [OffsetX, TILE_SIZE * 8], Size, 2, COLORS[28])
            
            
            if(SettingsState == SETTINGS_MUSIC_VOLUME)
                if(AnimationTimer < ANIMATION_TIME/2)
                    rl.DrawTextEx(Font, Settings.MusicVolume, [OffsetX + 9*TILE_SIZE, TILE_SIZE * 6], Size, 2, COLORS[26])
                endif
            else
                rl.DrawTextEx(Font, Settings.MusicVolume, [OffsetX + 9*TILE_SIZE, TILE_SIZE * 6], Size, 2, COLORS[26])
            endif
                
            if(SettingsState == SETTINGS_SOUND_VOLUME)
                if(AnimationTimer < ANIMATION_TIME/2)
                    rl.DrawTextEx(Font, Settings.SoundVolume, [OffsetX + 9*TILE_SIZE, TILE_SIZE * 7], Size, 2, COLORS[27])
                endif
            else
                rl.DrawTextEx(Font, Settings.SoundVolume, [OffsetX + 9*TILE_SIZE, TILE_SIZE * 7], Size, 2, COLORS[27])
            endif
            
            if(SettingsState == SETTINGS_WINDOW_SIZE)
                if(AnimationTimer < ANIMATION_TIME/2)
                    rl.DrawTextEx(Font, str(WindowSize), [OffsetX + 9*TILE_SIZE, TILE_SIZE * 8], Size, 2, COLORS[28])
                endif
            else
                rl.DrawTextEx(Font, str(WindowSize), [OffsetX + 9*TILE_SIZE, TILE_SIZE * 8], Size, 2, COLORS[28])
            endif
            
            if(AnimationTimer < ANIMATION_TIME/2)
                rl.DrawTextEx(Font, ">>", [OffsetX, TILE_SIZE * (Selection + 4)], Size, 2, COLORS[Selection + 24])
                if(AnimationTimer < 0) then AnimationTimer = ANIMATION_TIME
            endif
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer -= DeltaTime
        UpdateMusic()
        
    Until(GameState != GAMESTATE_SETTINGS)
    
    try
        tsave(PATH_TO_SETTINGS + "SETTINGS.DAT", Settings)      
    catch
        LOGPRINT "Can't save settings."
    end try
end



sub DoMenu()
    local OffsetX, Size, Selection, x, y, BugPosition, t
    OffsetX = TILE_SIZE * 12
    Size = TILE_SIZE/2
    Selection = 1

    CurrentLevel = 1
    AnimationTimer = 0
    UserLevelFile = 0
    Player.Score = 0
    
    Repeat
     
        if(rl.IsKeyPressed(c.KEY_ESCAPE) or rl.WindowShouldClose()) then
            GameState = GAMESTATE_QUIT_GAME
        endif
        
        if(rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER)) 
            
            select case Selection
                case 1  ' Start
                    LoadLevel(LevelList[1], FALSE)
                    GameState = GAMESTATE_LEVEL_IS_RUNNING
                case 2  ' User Level
                    GameState = GAMESTATE_USERFILE
                case 3  ' Settings
                    GameState = GAMESTATE_SETTINGS
                case 4  ' Highscore
                    GameState = GAMESTATE_HIGHSCORE
                case 5  ' Credits
                    GameState = GAMESTATE_CREDITS
                case 6  ' Editor
                    if(instr(sbver, "Win"))
                        exec("editor.bat")
                    else
                        exec(enclose("./sbasicg -r editor.bas"))
                    endif                    
                case 7  ' exit
                    GameState = GAMESTATE_QUIT_GAME
            end select
        endif            
        
        if(rl.IsKeyPressed(c.KEY_UP)) then
            rl.PlaySound(Sounds.Ping)
            Selection--
            if(Selection < 1) then Selection = 7           
        endif
        if(rl.IsKeyPressed(c.KEY_DOWN)) then
            rl.PlaySound(Sounds.Ping)
            Selection++
            if(Selection > 7) then Selection = 1           
        endif
 
        
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)     
            
            x = TILE_SIZE * 5.5
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3)
            rl.DrawTextureEx(LettersBug[1], [x, y], 0, TILE_SCALE, c.WHITE)
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+2*pi/9)
            rl.DrawTextureEx(LettersBug[2], [x + 2*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)    
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+4*pi/9) 
            rl.DrawTextureEx(LettersBug[3], [x + 4*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
            x = TILE_SIZE * 12.5
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+6*pi/9)                 
            rl.DrawTextureEx(LettersEscape[1], [x, y], 0, TILE_SCALE, c.WHITE)
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+8*pi/9) 
            rl.DrawTextureEx(LettersEscape[2], [x + 2*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)    
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+10*pi/9)  
            rl.DrawTextureEx(LettersEscape[3], [x + 4*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+12*pi/9) 
            rl.DrawTextureEx(LettersEscape[4], [x + 6*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+14*pi/9) 
            rl.DrawTextureEx(LettersEscape[5], [x + 8*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE) 
            y = TILE_SIZE + 0.25*TILE_SIZE*sin(t*3+16*pi/9) 
            rl.DrawTextureEx(LettersEscape[6], [x + 10*TILE_SIZE, y], 0, TILE_SCALE, c.WHITE)
                    
            rl.DrawTextureEx(MenuBG, [4.25*TILE_SIZE, 4*TILE_SIZE], 0, TILE_SCALE, c.WHITE)            
     
            rl.DrawRectangle(TILE_SIZE * 11, TILE_SIZE * 4, TILE_SIZE*9, TILE_SIZE*12, rl.ColorAlpha(c.BLACK, 0.8))
            rl.DrawTextEx(Font, "   START ",       [OffsetX, TILE_SIZE * 6], Size, 2, COLORS[3])
            rl.DrawTextEx(Font, "   USER LEVELS ", [OffsetX, TILE_SIZE * 7], Size, 2, COLORS[4])
            rl.DrawTextEx(Font, "   SETTINGS ",    [OffsetX, TILE_SIZE * 8], Size, 2, COLORS[5])
            rl.DrawTextEx(Font, "   HIGHSCORE ",   [OffsetX, TILE_SIZE * 9], Size, 2, COLORS[6])
            rl.DrawTextEx(Font, "   CREDITS ",     [OffsetX, TILE_SIZE * 10], Size, 2, COLORS[7])
            rl.DrawTextEx(Font, "   EDITOR ",      [OffsetX, TILE_SIZE * 11], Size, 2, COLORS[8])
            rl.DrawTextEx(Font, "   EXIT ",        [OffsetX, TILE_SIZE * 12], Size, 2, COLORS[9])
            
            if(AnimationTimer < ANIMATION_TIME/2)
                rl.DrawTextEx(Font, ">>", [OffsetX, TILE_SIZE * (Selection + 5)], Size, 2, COLORS[Selection + 2])
                if(AnimationTimer < 0) then AnimationTimer = ANIMATION_TIME
            endif
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer -= DeltaTime
        t += DeltaTime
        
        UpdateMusic()
       
    Until(GameState != GAMESTATE_MENU)
end


sub DoCredits
    local OffsetX, Size, Selection, CreditColors
    OffsetX = TILE_SIZE * 5
    Size = TILE_SIZE/2

    dim CreditColors[9]
    CreditColors[1] = COLORS[2]
    CreditColors[2] = COLORS[3]
    CreditColors[3] = COLORS[4]
    CreditColors[4] = COLORS[5]
    CreditColors[5] = COLORS[21]
    CreditColors[6] = COLORS[22]
    CreditColors[7] = COLORS[23]
    CreditColors[8] = COLORS[26]
    
    Repeat
        
        if(rl.IsKeyPressed(c.KEY_ESCAPE) OR rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER)) then
            GameState = GAMESTATE_MENU
        endif
    
        if(AnimationTimer < 0 ) then
		
            AnimationTimer = 0.1
            TempColor = CreditColors[8]
            
            for ii = 8 to 2 step -1
                CreditColors[ii] = CreditColors[ii - 1]
            next
            
            CreditColors[1] = TempColor
            
        end if
        
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            
            rl.DrawTextEx(Font, "CREDITS" , [TILE_SIZE*12, TILE_SIZE], Size*2, 2, Colors[27])
            
            rl.DrawTextEx(Font, ">> IDEA, GRAPHICS, SOUNDS, PROGRAMMING <<", [OffsetX, TILE_SIZE * 4], Size, 2, CreditColors[1])
            rl.DrawTextEx(Font, "                        J7M",               [OffsetX, TILE_SIZE * 5], Size, 2, Colors[29])
            rl.DrawTextEx(Font, "               >> LEVEL DESIGN <<",         [OffsetX, TILE_SIZE * 6], Size, 2, CreditColors[2])
            rl.DrawTextEx(Font, "                  J7M, HRKARLY",            [OffsetX, TILE_SIZE * 7], Size, 2, Colors[29])
            rl.DrawTextEx(Font, "                >> POWERED BY <<",   [OffsetX, TILE_SIZE * 8], Size, 2, CreditColors[3])
            rl.DrawTextEx(Font, "     SMALLBASIC -> SMALLBASIC.GITHUB.IO",         [OffsetX, TILE_SIZE * 9], Size, 2, Colors[29])
            rl.DrawTextEx(Font, "      RAYLIB, LINUX, PIXELORAMA, GEANY",         [OffsetX, TILE_SIZE * 10], Size, 2, Colors[29])
            rl.DrawTextEx(Font, "                   >> MUSIC <<",   [OffsetX, TILE_SIZE * 11], Size, 2, CreditColors[4])
            rl.DrawTextEx(Font, "Retro Indie Josh -> retroindiejosh.itch.io",         [OffsetX, TILE_SIZE * 12], Size, 2, Colors[29])                     
            rl.DrawTextEx(Font, "                (CC BY 4.0 Deed)",         [OffsetX, TILE_SIZE * 13], Size, 2, Colors[29])                     
                 
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer -= DeltaTime
        
        UpdateMusic()
       
    Until(GameState != GAMESTATE_CREDITS)

end

sub DoGameLoop()
    AnimationTimer = 0
    Repeat

        if(rl.IsKeyPressed(c.KEY_ESCAPE)) then
            GameState = GAMESTATE_MENU
            rl.PollInputEvents()
        endif
        if(rl.WindowShouldClose()) then Gamestate = GAMESTATE_QUIT_GAME
        
        select case GameState
            case GAMESTATE_LEVEL_IS_RUNNING
                rl.BeginDrawing()
                    rl.ClearBackground(c.BLACK)            
                    DrawScore()
                    DrawBoard()
                    DrawPlayer()
                    DrawTrapCounter()
                    DrawEnemies()
                    EnemyHitPlayer()
                    SoundEnemies()              
                rl.EndDrawing         
                GameLoop_UpdateKeys()               
            case GAMESTATE_PLAYER_IS_MOVING
                rl.BeginDrawing()                
                    rl.ClearBackground(c.BLACK)            
                    SoundTrap()  
                    DrawScore()
                    DrawBoard()
                    DrawPlayerIsMoving()
                    DrawTrapCounter() 
                    DrawEnemies()
                    EnemyHitPlayer()                                          
                rl.EndDrawing
            case GAMESTATE_PLAYER_WILL_DIE_ANIMATION
                rl.BeginDrawing()
                    rl.ClearBackground(c.BLACK)            
                    SoundPlayerWillDie()
                    DrawScore()
                    DrawBoard()
                    DrawPlayerWillDie()
                    DrawEnemies()                
                rl.EndDrawing
            case GAMESTATE_PLAYER_COLLECT_BONUS
                rl.BeginDrawing()                
                    rl.ClearBackground(c.BLACK)  
                    SoundBonus()          
                    DrawScore()
                    DrawBoard()
                    DrawPlayerCollectBonus()
                    DrawTrapCounter()
                    DrawEnemies()           
                rl.EndDrawing                   
            case GAMESTATE_PLAYER_AT_EXIT
                rl.BeginDrawing()                
                    rl.ClearBackground(c.BLACK)
                    SoundExit()    
                    DrawScore()
                    DrawBoard()
                    DrawEnemies()
                    DrawPlayerAtExit()             
                rl.EndDrawing    
            case GAMESTATE_TOGGLE_FLAG
                rl.BeginDrawing()
                    rl.ClearBackground(c.BLACK)            
                    DrawScore()
                    DrawBoard()
                    DrawPlayer()
                    DrawTrapCounter()
                    DrawFlag()
                    DrawEnemies()
                    EnemyHitPlayer()
                    SoundEnemies()              
                rl.EndDrawing         
                ToggleFlag_UpdateKeys()               
        end select
        
        DeltaTime = rl.GetFrameTime()
        AnimationTimer = AnimationTimer - DeltaTime
        if(AnimationTimer < 0) then AnimationTimer = ANIMATION_TIME
        UpdateMusic()

    Until(GameState == GAMESTATE_LEVEL_FINISHED OR GameState == GAMESTATE_GAME_OVER OR GameState == GAMESTATE_MENU OR GameState == GAMESTATE_QUIT_GAME)

end

sub ToggleFlag_UpdateKeys()
    
    if(rl.IsKeyPressed(c.KEY_UP)) 
        if(Player.FlagPosition[2] > Player.PositionY - 2) then Player.FlagPosition[2]--
        if(Player.FlagPosition[1] == Player.PositionX - 1 AND Player.FlagPosition[2] == Player.PositionY - 1) then Player.FlagPosition[2]--          
    endif
    if(rl.IsKeyPressed(c.KEY_DOWN)) 
        if(Player.FlagPosition[2] < Player.PositionY ) then Player.FlagPosition[2]++
        if(Player.FlagPosition[1] == Player.PositionX - 1 AND Player.FlagPosition[2] == Player.PositionY - 1) then Player.FlagPosition[2]++         
    endif
    if(rl.IsKeyPressed(c.KEY_RIGHT)) 
        if(Player.FlagPosition[1] < Player.PositionX ) then Player.FlagPosition[1]++
        if(Player.FlagPosition[1] == Player.PositionX - 1 AND Player.FlagPosition[2] == Player.PositionY - 1) then Player.FlagPosition[1]++  
    endif
    if(rl.IsKeyPressed(c.KEY_LEFT))
        if(Player.FlagPosition[1] > Player.PositionX - 2) then Player.FlagPosition[1]--
        if(Player.FlagPosition[1] == Player.PositionX - 1 AND Player.FlagPosition[2] == Player.PositionY - 1) then Player.FlagPosition[1]--      
    endif
    
    if(rl.IsKeyPressed(c.KEY_SPACE)) 
        local index
        
        index = GetBoardIndex(Player.FlagPosition[1] + 1 , Player.FlagPosition[2] + 1)
        if(index > 0 AND Board[index].Flag_Tile) 
            Board[index].Flag_Tile = 0
        else
            Board[index].Flag_Tile = Player.TileFlag
        endif
        GameState = GAMESTATE_LEVEL_IS_RUNNING
    endif
end

sub DrawFlag()
    if(AnimationTimer < 0.5 * ANIMATION_TIME)
        local pos
        
        pos.x = Player.FlagPosition[1] * TILE_SIZE
        pos.y = Player.FlagPosition[2] * TILE_SIZE + TILE_SIZE ' SCORE_HEIGHT
        
        rl.DrawTextureEx(Tiles[Player.TileFlag].Texture, pos, 0, TILE_SCALE, c.WHITE)   
    endif
end

sub DoHighscore()
    local OffsetX, Size, Selection, HighscoreColors, HighScore, pos, temp, editpos, tempchar, tempstr, AnimationTimer
    OffsetX = TILE_SIZE * 12
    Size = TILE_SIZE * 0.5
    pos = 0
    editpos = 1

    dim HighscoreColors
    HighscoreColors << COLORS[2]
    HighscoreColors << COLORS[3]
    HighscoreColors << COLORS[4]
    HighscoreColors << COLORS[5]
    HighscoreColors << COLORS[21]
    HighscoreColors << COLORS[22]
    HighscoreColors << COLORS[23]
    HighscoreColors << COLORS[24]
    HighscoreColors << COLORS[25]
    HighscoreColors << COLORS[26]
    
    try
        tload PATH_TO_SETTINGS + "HIGHSCORE.DAT", Highscore
        for ii = 1 to 10 do Highscore[ii] = array(Highscore[ii])        
    catch
        Highscore << {Name: "J7M", Score: 100}
        Highscore << {Name: "HRK", Score: 90}
        Highscore << {Name: "EMI", Score: 80}
        Highscore << {Name: "BOB", Score: 70}
        Highscore << {Name: "ADA", Score: 60}
        Highscore << {Name: "FEN", Score: 50}
        Highscore << {Name: "XYZ", Score: 40}
        Highscore << {Name: "T3T", Score: 30}
        Highscore << {Name: "7O9", Score: 20}
        Highscore << {Name: "3CP", Score: 10}
    end try
    
    ' Find highscore position and insert data
    for ii = 10 to 1 step -1
        if(Highscore(ii).Score < Player.Score) then pos = ii
    next
    
    if(pos > 0)
        temp.Name = "???"
        temp.Score = Player.Score
        insert Highscore, pos, temp
        delete Highscore, 11
    endif   
    
    rl.PollInputEvents()           ' Call for update keys, otherwise SB dosen't
                                   ' realize, that RETURN is not pressed anymore    
    
    Repeat

        if(rl.IsKeyPressed(c.KEY_ESCAPE) OR rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER)) then
            GameState = GAMESTATE_MENU
        endif
        if(rl.WindowShouldClose()) then Gamestate = GAMESTATE_QUIT_GAME
    
        if(pos > 0)
            if(rl.IsKeyPressed(c.KEY_UP))
                rl.PlaySound(Sounds.Ping)
                tempstr = Highscore(pos).Name
                tempchar = asc(mid(tempstr, editpos, 1)) + 1
                if(tempchar > 90) then tempchar = 48
                tempchar = chr(tempchar)
                tempstr = replace(tempstr, editpos, tempchar, 1)
                Highscore(pos).Name = tempstr
            endif             
            if(rl.IsKeyPressed(c.KEY_DOWN))
                rl.PlaySound(Sounds.Ping)
                tempstr = Highscore(pos).Name
                tempchar = asc(mid(tempstr, editpos, 1)) - 1
                if(tempchar < 48) then tempchar = 90
                tempchar = chr(tempchar)
                tempstr = replace(tempstr, editpos, tempchar, 1)
                Highscore(pos).Name = tempstr
            endif
            if(rl.IsKeyPressed(c.KEY_RIGHT))
                rl.PlaySound(Sounds.Ping)
                editpos++
                if(editpos > 3) then editpos = 1
            endif
            if(rl.IsKeyPressed(c.KEY_LEFT))
                rl.PlaySound(Sounds.Ping)
                editpos--
                if(editpos < 1) then editpos = 3
            endif
        endif
    
        if(AnimationTimer < 0 ) then
            AnimationTimer = 0.1
            TempColor = HighscoreColors[10]
            
            for ii = 10 to 2 step -1
                HighscoreColors[ii] = HighscoreColors[ii - 1]
            next
            
            HighscoreColors[1] = TempColor
            
        endif
        
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            
            rl.DrawTextEx(Font, "HIGHSCORE" , [TILE_SIZE*11, TILE_SIZE], Size*2, 2, Colors[27])
            if(pos > 0)
                rl.DrawTextEx(Font, "USE ARROW KEYS OR" , [TILE_SIZE*20, TILE_SIZE * 3], Size, 2, Colors[3])
                rl.DrawTextEx(Font, "D-PAD TO ENTER" , [TILE_SIZE*20, TILE_SIZE * 4], Size, 2, Colors[3])
                rl.DrawTextEx(Font, "NAME. CONFIRM WITH" , [TILE_SIZE*20, TILE_SIZE * 5], Size, 2, Colors[3])  
                rl.DrawTextEx(Font, "SPACE OR FIRE" , [TILE_SIZE*20, TILE_SIZE * 6], Size, 2, Colors[3])                
            endif
            
            for ii = 1 to 10
                if(pos > 0 AND ii == pos)
                    if(AnimationTimer < 0.05)
                        rl.DrawTextEx(Font, ">> " + Highscore[ii].Name , [OffsetX, TILE_SIZE * (ii + 2)], Size, 2, c.WHITE)
                        rl.DrawTextEx(Font, str(Highscore[ii].Score), [OffsetX + TILE_SIZE*5, TILE_SIZE * (ii + 2)], Size, 2, c.WHITE)
                    endif
                else
                    rl.DrawTextEx(Font, Highscore[ii].Name , [OffsetX, TILE_SIZE * (ii + 2)], Size, 2, HighscoreColors[ii])
                    rl.DrawTextEx(Font, Highscore[ii].Score, [OffsetX + TILE_SIZE*5, TILE_SIZE * (ii + 2)], Size, 2, HighscoreColors[ii])
                endif
            next
          
        rl.EndDrawing      
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer -= DeltaTime
        UpdateMusic()
       
    Until(GameState != GAMESTATE_HIGHSCORE AND GameState != GAMESTATE_GAME_OVER AND GameState != GAMESTATE_GAME_FINISHED)   
    
    tsave PATH_TO_SETTINGS + "HIGHSCORE.DAT", Highscore
end

sub DoScoreUpdate()
    local OffsetX, Size, Temp, LevelScore = 200
    OffsetX = TILE_SIZE * 12
    Size = TILE_SIZE/2
    TempPlayerLives = Player.Lives

    
    rl.WaitTime(1)
    
    Repeat
        rl.BeginDrawing()                
            rl.ClearBackground(c.BLACK)            
            rl.DrawTextEx(Font, "   LEVEL : " + Format("0000", LevelScore),      [OffsetX, TILE_SIZE * 5], Size, 2, COLORS[25])
            rl.DrawTextEx(Font, "   STEPS : " + Format("0000", Player.Steps),    [OffsetX, TILE_SIZE * 6], Size, 2, COLORS[26])
            rl.DrawTextEx(Font, "   LIVES : " + Format("0000", TempPlayerLives), [OffsetX + 0.12*TILE_SIZE, TILE_SIZE * 7], Size, 2, COLORS[27])
            rl.DrawTextEx(Font, "--------------",                                [OffsetX, TILE_SIZE * 8], Size, 2, COLORS[28])
            rl.DrawTextEx(Font, ">> SCORE : " + Format("0000", Player.Score),    [OffsetX - 0.25*TILE_SIZE, TILE_SIZE * 9], Size, 2, COLORS[29])
        rl.EndDrawing         
                
        DeltaTime = rl.GetFrameTime()
        AnimationTimer = AnimationTimer - DeltaTime
        
        if(AnimationTimer < 0)
            if(LevelScore >= 0.5)
                rl.PlaySound(Sounds.Ping)
                AnimationTimer = ANIMATION_TIME/20
                LevelScore--
                Player.Score++
            elseif(Player.Steps >= 0.5)
                rl.PlaySound(Sounds.Ping)
                AnimationTimer = ANIMATION_TIME/6
                Player.Steps--                
                if(Player.Score > 0) then Player.Score--
            elseif(TempPlayerLives > 0)
                rl.PlaySound(Sounds.Ping)
                AnimationTimer = ANIMATION_TIME*2
                Player.Score = Player.Score + 10 * TempPlayerLives
                TempPlayerLives--
            else
                AnimationTimer = ANIMATION_TIME
                rl.DrawTextEx(Font, ">> PRESS BUTTON << ",  [OffsetX - TILE_SIZE * 0.8, TILE_SIZE * 11], Size, 2, COLORS[23])
            endif
        endif
        
    Until(rl.IsKeyPressed(c.KEY_ESCAPE) OR rl.IsKeyPressed(c.KEY_SPACE) OR rl.IsKeyPressed(c.KEY_ENTER))
end

sub DrawPlayerAtExit()
    local tile, pos

    tile = Tiles[Player.Tile]
    pos.x = (Player.PositionX - 1) * TILE_SIZE
    pos.y = Player.PositionY * TILE_SIZE ' SCORE_HEIGHT
    
    if(AnimationTimer == ANIMATION_TIME) then Player.Tile = tile.next        
            
    
    if(Player.PlayerMoving.s > 0) then
        ' Player still moving
        Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED
        pos.x = pos.x + Player.PlayerMoving.x * Player.PlayerMoving.s
        pos.y = pos.y + Player.PlayerMoving.y * Player.PlayerMoving.s
        rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
    else
        ' Player arrives -> do animation
        ' Use PlayerMoving.s as animation timer
        Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED * 300
        RecSrc = [1,1,32,32]
        TextureSize = TILE_SIZE * (1 - Player.PlayerMoving.s/360)
        RecDest = [pos.x + 0.5 * TILE_SIZE, pos.y + 0.5 * TILE_SIZE, TextureSize, TextureSize]
        Origin = [TextureSize/2, TextureSize/2]
        rl.DrawTexturePro(tile.Texture, RecSrc, RecDest, Origin, Player.PlayerMoving.s, c.WHITE)
              
        if(Player.PlayerMoving.s < -720)
            GameState = GAMESTATE_LEVEL_FINISHED
            PlaySoundOnce = true
        endif
        
    endif
    
end

sub DrawPlayerCollectBonus()
    local tile, pos, BonusTile, index, RecSrc, TextureSize, RecDest, Origin, BonusColor, ScoreText

    tile = Tiles[Player.Tile]
    pos.x = (Player.PositionX - 1) * TILE_SIZE
    pos.y = Player.PositionY * TILE_SIZE ' SCORE_HEIGHT
    
    if(Player.PlayerMoving.s > 0) then
        ' Player still moving        
        if(AnimationTimer == ANIMATION_TIME) then Player.Tile = tile.next              
        Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED
        pos.x = pos.x + Player.PlayerMoving.x * Player.PlayerMoving.s
        pos.y = pos.y + Player.PlayerMoving.y * Player.PlayerMoving.s
        rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
    else
        ' Player arrives -> do animation
        ' Use PlayerMoving.s as animation timer
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        Board[index].Bonus_Tile = 0
        select case Board[index].Bonus_Name
            case 1
                BonusTile = Tiles[Bonus.TileBonus1].Texture
                ScoreText = str(BONUS_SCORE_1)
            case 2
                BonusTile = Tiles[Bonus.TileBonus2].Texture
                ScoreText = "STEPS"
            case 3
                BonusTile = Tiles[Bonus.TileBonus3].Texture
                ScoreText = str(BONUS_SCORE_2)
            case 4
                BonusTile = Tiles[Bonus.TileBonusLive].Texture
                ScoreText = "LIVE"
        end select
            
        rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
        
        Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED * 400
        RecSrc = [1,1,32,32]
        TextureSize = TILE_SIZE * (1 - Player.PlayerMoving.s/360) 
        RecDest = [pos.x + 0.5 * TILE_SIZE, pos.y + 0.5 * TILE_SIZE, TextureSize, TextureSize]
        Origin = [TextureSize/2, TextureSize/2]
        BonusColor = rl.ColorAlpha(c.WHITE, 1 + Player.PlayerMoving.s/360)
        rl.DrawTexturePro(BonusTile, RecSrc, RecDest, Origin, 0, BonusColor)
        rl.DrawTextEx(Font, ScoreText, [pos.x + 0.5 * TILE_SIZE, pos.y], TextureSize/3, 2, BonusColor)
         
              
        if(Player.PlayerMoving.s < -360)           
            select case Board[index].Bonus_Name
                case 1
                    Player.Score = Player.Score + BONUS_SCORE_1 
                case 2
                    Player.Steps = Player.Steps - BONUS_STEPS
                    if(Player.Steps < 0) then Player.Steps = 0
                case 3
                    Player.Score = Player.Score + BONUS_SCORE_2
                case 4
                    Player.Lives = Player.Lives + 1
            end select
            Board[index].Bonus_Name = 0
            GameState = GAMESTATE_LEVEL_IS_RUNNING
            PlaySoundOnce = true
            Player.PlayerMoving.s = 0
        endif
        
    endif
    
end


sub DrawScore()
    local Size, posy, OffsetX
    Size = 0.7 * TILE_SIZE
    posy = TILE_SIZE / 16
    OffsetX = 2 * TILE_SIZE
   
    rl.DrawTextEx(Font, ">>>> SCORE: " + Format("0000", Player.Score),          [OffsetX,                  posy], Size, 2, COLORS[25])
    rl.DrawTextEx(Font, "LIVES: "      + Format("00", Player.Lives),            [TILE_SIZE * 10.7 + OffsetX,  posy], Size, 2, COLORS[26])
    rl.DrawTextEx(Font, "STEPS: "      + Format("0000", Player.Steps) + " <<<<", [TILE_SIZE * 17 + OffsetX, posy], Size, 2, COLORS[27])
end

sub PlayerDied()
    index = GetBoardIndex(Player.PositionX, Player.PositionY)
    if(Board[index].Trap) then Board[index].Flag_Tile = Player.TileFlag
    Player.PositionX = Player.StartPosition[1]
    Player.PositionY = Player.StartPosition[2]
    Player.Tile = Player.StartTile
    Player.Lives--
    GameState = GAMESTATE_LEVEL_IS_RUNNING
    if(Player.Lives < 1)
        GameState = GAMESTATE_GAME_OVER
        PlaySoundOnce = true      
    endif
    UpdateTrapCounter()
    
end

sub UpdateTrapCounter()
    local index
    TrapCounter = 0
    
    index = GetBoardIndex(Player.PositionX - 1, Player.PositionY - 1)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX    , Player.PositionY - 1)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX + 1, Player.PositionY - 1)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX - 1, Player.PositionY)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX + 1, Player.PositionY)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX - 1, Player.PositionY + 1)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX    , Player.PositionY + 1)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
    index = GetBoardIndex(Player.PositionX + 1, Player.PositionY + 1)
    if(index > 0 AND Board[index].Trap) then TrapCounter++
    
end

sub DrawTrapCounter()
    local pos

    if(TrapCounter)
     
        pos.x = (Player.PositionX - 1) * TILE_SIZE  + TILE_SIZE/2
        pos.y = Player.PositionY * TILE_SIZE  + TILE_SIZE/2 ' SCORE_HEIGHT

        pos.x = pos.x + Player.PlayerMoving.x * Player.PlayerMoving.s
        pos.y = pos.y + Player.PlayerMoving.y * Player.PlayerMoving.s
     
        
        
        rl.DrawCircle(pos.x, pos.y, TILE_SIZE/4, rl.ColorAlpha(COLORS[15], 0.8) )  
        
        for ii = TrapCounter to 1 step -1
            rl.DrawCircleSector(     pos, TILE_SIZE/4, 180 - (ii-1) / 7 * 360 , 180 - ii / 7 * 360, 7, COLORS[17 + ii])
            rl.DrawCircleSectorLines(pos, TILE_SIZE/4, 180 - (ii-1) / 7 * 360 , 180 - ii / 7 * 360, 7, COLORS[5])        
        next
        'rl.DrawText(str(TrapCounter), pos.x - TILE_SIZE / 8, pos.y - TILE_SIZE / 4, TILE_SIZE/2, COLORS[11])
    endif
end

sub DrawBoard()
    local yy, xx, index, tile, t, pos

    for yy = 1 to BOARD_SIZE_Y
        for xx = 1 to BOARD_SIZE_X
            
            index = (yy - 1) * BOARD_SIZE_X + xx
            pos.x = (xx - 1) * TILE_SIZE
            pos.y = yy * TILE_SIZE ' SCORE_HEIGHT
            
            t = Board[index].BG_Tile  
            if(t) 
                tile = Tiles[t]
                rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)                
                Board[index].BG_AnimationTime -= DeltaTime
                if(Board[index].BG_AnimationTime <= 0)
                    Board[index].BG_AnimationTime = tile.AnimationDuration
                    Board[index].BG_Tile = tile.next
                endif
            endif
            t = Board[index].Footsteps  
            if(t)                 
                tile = Tiles[t]
                rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
            endif
            t = Board[index].Bonus_Tile            
            if(t)
                tile = Tiles[t]
                rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
                Board[index].Bonus_AnimationTime -= DeltaTime
                if(Board[index].Bonus_AnimationTime <= 0)
                    Board[index].Bonus_AnimationTime = tile.AnimationDuration
                    Board[index].Bonus_Tile = tile.next
                endif
            endif
            t = Board[index].Exit_Tile            
            if(t) 
                tile = Tiles[t]
                rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
                Board[index].Exit_AnimationTime -= DeltaTime
                if(Board[index].Exit_AnimationTime <= 0)
                    Board[index].Exit_AnimationTime = tile.AnimationDuration
                    Board[index].Exit_Tile = tile.next
                endif
            endif
            t = Board[index].Flag_Tile            
            if(t)
                tile = Tiles[t]
                rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
                Board[index].Flag_AnimationTime -= DeltaTime
                if(Board[index].Flag_AnimationTime <= 0)
                    Board[index].Flag_AnimationTime = tile.AnimationDuration
                    Board[index].Flag_Tile = tile.next
                endif
            endif
        next
    next    
end

sub DrawPlayerWillDie()
    local tile, pos

    tile = Tiles[Player.Tile]
    pos.x = (Player.PositionX - 1) * TILE_SIZE
    pos.y = Player.PositionY * TILE_SIZE  ' SCORE_HEIGHT
    
    if(AnimationTimer == ANIMATION_TIME) then Player.Tile = tile.next        
            
    
    if(Player.PlayerMoving.s > 0) then
        ' Player still moving
        Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED
        pos.x = pos.x + Player.PlayerMoving.x * Player.PlayerMoving.s
        pos.y = pos.y + Player.PlayerMoving.y * Player.PlayerMoving.s
        rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
    else
        ' Player arrives -> do animation
        ' Use PlayerMoving.s as animation timer
        Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED * 100
        rl.DrawCircle(pos.x + 0.5 * TILE_SIZE, pos.y + 0.5 * TILE_SIZE, TILE_SIZE*0.35, COLORS[11])
        RecSrc = [1,1,32,32]
        TextureSize = TILE_SIZE * (1 + Player.PlayerMoving.s/360) 
        RecDest = [pos.x + 0.5 * TILE_SIZE, pos.y + 0.5 * TILE_SIZE, TextureSize, TextureSize]
        Origin = [TextureSize/2, TextureSize/2]
        rl.DrawTexturePro(tile.Texture, RecSrc, RecDest, Origin, Player.PlayerMoving.s, c.WHITE)
              
        if(Player.PlayerMoving.s < -360)
            PlayerDied()
        endif
        
    endif
    
end

sub DrawPlayerIsMoving()
    local tile, pos

    tile = Tiles[Player.Tile]
    pos.x = (Player.PositionX - 1) * TILE_SIZE
    pos.y = Player.PositionY * TILE_SIZE 'SCORE_HEIGHT
        
    if(AnimationTimer == ANIMATION_TIME) then Player.Tile = tile.next        
    
    Player.PlayerMoving.s = Player.PlayerMoving.s - DeltaTime * PLAYER_SPEED
    if(Player.PlayerMoving.s <= 0) 
        GameState = GAMESTATE_LEVEL_IS_RUNNING
        PlaySoundOnce = true
    endif
    
    pos.x = pos.x + Player.PlayerMoving.x * Player.PlayerMoving.s
    pos.y = pos.y + Player.PlayerMoving.y * Player.PlayerMoving.s
    rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
    
    if(!rl.IsSoundPlaying(Sounds.Step)) then rl.PlaySound(Sounds.Step)
    
end


sub DrawPlayer()
    local tile, pos

    tile = Tiles[Player.Tile]
    pos.x = (Player.PositionX - 1) * TILE_SIZE
    pos.y = Player.PositionY * TILE_SIZE   ' SCORE_HEIGHT
    'rl.DrawTexture(tile.Texture, (Player.PositionX - 1) * TILE_SIZE, (Player.PositionY - 1) * TILE_SIZE, c.WHITE)
    
    rl.DrawTextureEx(tile.Texture, pos, 0, TILE_SCALE, c.WHITE)
    
end

sub GameLoop_UpdateKeys()
    if(rl.IsKeyDown(c.KEY_UP)) then
        index = GetBoardIndex(Player.PositionX, Player.PositionY - 1)
        
        if(index < 0 OR Board[index].Block) then
            if(!rl.IsSoundPlaying(Sounds.Block)) then rl.PlaySound(Sounds.Block)
            return
        endif
        
        GameState = GAMESTATE_PLAYER_IS_MOVING
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        Board[index].Footsteps = Player.Footsteps
        
        Player.PositionY--
        Player.Tile = Player.TileUp
        Player.PlayerMoving.x = 0
        Player.PlayerMoving.y = TILE_SIZE
        Player.PlayerMoving.s = 1
        Player.Steps++
        
        UpdateTrapCounter()
        
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        if(Board[index].Trap) then GameState = GAMESTATE_PLAYER_WILL_DIE_ANIMATION
        if(Board[index].Bonus_Name) then GameState = GAMESTATE_PLAYER_COLLECT_BONUS
        if(Board[index].Exit_Tile) then GameState = GAMESTATE_PLAYER_AT_EXIT
        
    endif
    if(rl.IsKeyDown(c.KEY_DOWN)) then
        index = GetBoardIndex(Player.PositionX, Player.PositionY + 1)        
        if(index < 0 OR Board[index].Block) then
            if(!rl.IsSoundPlaying(Sounds.Block)) then rl.PlaySound(Sounds.Block)
            return
        endif
                        
        GameState = GAMESTATE_PLAYER_IS_MOVING 
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        Board[index].Footsteps = Player.Footsteps
        
        Player.PositionY++
        Player.Tile = Player.TileDown
        Player.PlayerMoving.x = 0
        Player.PlayerMoving.y = -TILE_SIZE
        Player.PlayerMoving.s = 1
        Player.Steps++
        
                    
        UpdateTrapCounter()
        
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        if(Board[index].Trap) then GameState = GAMESTATE_PLAYER_WILL_DIE_ANIMATION
        if(Board[index].Bonus_Name) then GameState = GAMESTATE_PLAYER_COLLECT_BONUS
        if(Board[index].Exit_Tile) then GameState = GAMESTATE_PLAYER_AT_EXIT
        
        
    endif
    if(rl.IsKeyDown(c.KEY_LEFT)) then
        index = GetBoardIndex(Player.PositionX - 1, Player.PositionY)        
        if(index < 0 OR Board[index].Block) then
            if(!rl.IsSoundPlaying(Sounds.Block)) then rl.PlaySound(Sounds.Block)
            return
        endif
        
        GameState = GAMESTATE_PLAYER_IS_MOVING    
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        Board[index].Footsteps = Player.Footsteps
        
        Player.PositionX--
        Player.Tile = Player.TileLeft
        Player.PlayerMoving.x = TILE_SIZE
        Player.PlayerMoving.y = 0
        Player.PlayerMoving.s = 1
        Player.Steps++
        
        UpdateTrapCounter()
        
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        if(Board[index].Trap) then GameState = GAMESTATE_PLAYER_WILL_DIE_ANIMATION
        if(Board[index].Bonus_Name) then GameState = GAMESTATE_PLAYER_COLLECT_BONUS
        if(Board[index].Exit_Tile) then GameState = GAMESTATE_PLAYER_AT_EXIT
        
        
    endif
    if(rl.IsKeyDown(c.KEY_RIGHT)) then
        index = GetBoardIndex(Player.PositionX + 1, Player.PositionY)        
        if(index < 0 OR Board[index].Block) then
            if(!rl.IsSoundPlaying(Sounds.Block)) then rl.PlaySound(Sounds.Block)
            return
        endif
        
        GameState = GAMESTATE_PLAYER_IS_MOVING                
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        Board[index].Footsteps = Player.Footsteps
        
        Player.PositionX++
        Player.Tile = Player.TileRight
        Player.PlayerMoving.x = -TILE_SIZE
        Player.PlayerMoving.y = 0
        Player.PlayerMoving.s = 1
        Player.Steps++
        
        UpdateTrapCounter()
        
        index = GetBoardIndex(Player.PositionX, Player.PositionY)
        if(Board[index].Trap) then GameState = GAMESTATE_PLAYER_WILL_DIE_ANIMATION
        if(Board[index].Bonus_Name) then GameState = GAMESTATE_PLAYER_COLLECT_BONUS
        if(Board[index].Exit_Tile) then GameState = GAMESTATE_PLAYER_AT_EXIT
        
    endif
    if(rl.IsKeyPressed(c.KEY_SPACE) or rl.IsKeyPressed(c.KEY_ENTER)) then
        GameState = GAMESTATE_TOGGLE_FLAG
        Player.FlagPosition = [Player.PositionX - 1, Player.PositionY - 2]
    endif  
end

func GetBoardIndex(X,Y)
    if(X < 1)            then return -1
    if(X > BOARD_SIZE_X) then return -1
    if(Y < 1)            then return -1
    if(Y > BOARD_SIZE_Y) then return -1
       
    return (Y - 1) * BOARD_SIZE_X + X
end

sub LoadLevel(LevelName, UserLevel)
    local FileNames, ii, f, TileSet_FileName, temp, temp1
    
    if(!UserLevel)
        LevelName = PATH_TO_DATA + "LEVELS/" + LevelName
    endif
    
    tload LevelName, d
    
    temp = array(d[1])    
    
    TileSet_FileName = PATH_TO_DATA + temp.TileSet
    LoadTiles(TileSet_FileName)
    
    temp = array(d[2])    
    Player.Tile = temp.PlayerTile    
    Player.StartTile = temp.PlayerTile
    Player.PositionX = temp.PlayerX
    Player.PositionY = temp.PlayerY
    Player.StartPosition = [temp.PlayerX, temp.PlayerY]
    
    dim Board
    dim Enemies
    ii = 2
    for yy = 1 to BOARD_SIZE_Y
        for xx = 1 to BOARD_SIZE_X
            ii++
            temp = array(d[ii])
            temp1.BG_Tile = temp.BG_Tile
            temp1.Bonus_Tile = temp.Bonus_Tile
            temp1.Bonus_Name = temp.Bonus_Name
            temp1.Exit_Tile = temp.Exit_Tile
            temp1.Flag_Tile = 0
            temp1.Trap = temp.Trap
            temp1.Block = temp.Block
            temp1.Footsteps = 0
            temp1.Flag_Tile = 0
            temp1.BG_AnimationTime = Tiles[temp.BG_Tile].AnimationDuration
            temp1.Bonus_AnimationTime = 0
            temp1.Exit_AnimationTime = 0    
            temp1.Flag_AnimationTime = 0
            Board << temp1            
            
            if(temp.Enemy_Name)
                dim temp1
                temp1.Enemy_Tile = temp.Enemy_Tile
                temp1.Enemy_Name = temp.Enemy_Name
                temp1.x = xx
                temp1.y = yy
                if(temp.Enemy_Name == 1)
                    temp1.MovingVector = {x:1, y:0, s:0}
                else
                    temp1.MovingVector = {x:0, y:1, s:0}
                endif
                Enemies << temp1
            endif
        next
    next
    
    NumberOfEnemies = len(Enemies)
end


sub LoadTiles(TileSet_FileName)
    local TileSet, temp, NumberOfLines, xx, yy, ii
    
    UnloadTiles()
    
    dim Tiles
    
    tload TileSet_FileName, TileSet
    NumberOfLines = ubound(TileSet)
    ii++
    temp = array(TileSet[ii])
    Player.TileUp = temp.Player_up
    Player.TileDown = temp.Player_down
    Player.TileLeft = temp.Player_left
    Player.TileRight = temp.Player_right
    Player.Footsteps = temp.Footsteps
    Player.TileFlag = temp.Flag
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
        tile.Texture = rl.LoadTexture(PATH_TO_DATA + temp.Tile)
        tile.next = temp.Next
        tile.AnimationDuration = temp.AnimationDuration
        if tile.AnimationDuration == 0 then tile.AnimationDuration = ANIMATION_TIME
        Tiles << tile
    wend
    
end

sub SetFullScreen()
    local MonitorX, MonitorY, Monitor
    Monitor = rl.GetCurrentMonitor()
    MonitorX = rl.GetMonitorWidth(Monitor)
    MonitorY = rl.GetMonitorHeight(Monitor)
    TILE_SIZE = min( floor(MonitorX / BOARD_SIZE_X), floor(MonitorY / BOARD_SIZE_Y+ 2))
    TILE_SCALE = TILE_SIZE / 32   
    SCREEN_X = MonitorX
    SCREEN_Y = MonitorY
    rl.SetWindowSize(SCREEN_X, SCREEN_Y)
    rl.ToggleFullscreen()
end

sub SetWindowScreen()
    TILE_SIZE                 = 32 * Settings.WindowScale
    TILE_SCALE                = TILE_SIZE / 32
    SCREEN_X = BOARD_SIZE_X * TILE_SIZE
    SCREEN_Y = BOARD_SIZE_Y * (TILE_SIZE + 2)
    rl.ToggleFullscreen()
    rl.SetWindowSize(SCREEN_X, SCREEN_Y)
end

sub SoundTrap()    
    if(PlaySoundOnce AND AnimationTimer >= ANIMATION_TIME)
        select case TrapCounter
            case 0
            case 1: rl.PlaySound(Sounds.Trap1)
            case 2: rl.PlaySound(Sounds.Trap2)
            case 3: rl.PlaySound(Sounds.Trap3)
            case 4: rl.PlaySound(Sounds.Trap4)
            case 5: rl.PlaySound(Sounds.Trap5)
            case 6: rl.PlaySound(Sounds.Trap6)
            case 7: rl.PlaySound(Sounds.Trap7)
        end select
        PlaySoundOnce = false
    endif   
end

sub SoundPlayerWillDie()
    if(PlaySoundOnce AND Player.PlayerMoving.s < 0)
        rl.PlaySound(Sounds.PlayerWillDie)
        PlaySoundOnce = false
    endif    
end

sub SoundBonus()
    if(PlaySoundOnce AND Player.PlayerMoving.s < 0)
        rl.PlaySound(Sounds.Bonus)
        PlaySoundOnce = false
    endif    
end

sub SoundExit()
    if(PlaySoundOnce AND Player.PlayerMoving.s < 0)
        rl.PlaySound(Sounds.Exit)
        PlaySoundOnce = false
    endif    
end

sub SoundEnemies()    
    if(AnimationTimer >= ANIMATION_TIME AND NumberOfEnemies > 0)
        Distance = 10000000
        for ii = 1 to NumberOfEnemies
            Distance = min( (Player.PositionX - Enemies[ii].x)^2 + (Player.PositionY - Enemies[ii].y)^2 , Distance)
        next
        
        If(Distance < 2) then Distance = 2
        rl.SetSoundVolume(Sounds.Enemies, 2/Distance)
        if(!rl.IsSoundPlaying(Sounds.Enemies)) then rl.PlaySound(Sounds.Enemies)
    endif
end

sub LoadSounds()
    Sounds.Trap1 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap1.ogg")
    Sounds.Trap2 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap2.ogg")
    Sounds.Trap3 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap3.ogg")    
    Sounds.Trap4 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap4.ogg")    
    Sounds.Trap5 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap5.ogg")    
    Sounds.Trap6 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap6.ogg")    
    Sounds.Trap7 = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Trap7.ogg")
    Sounds.PlayerWillDie = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Dead.ogg")
    Sounds.Bonus = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Bonus.ogg")
    Sounds.Exit = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Exit.ogg")
    Sounds.Block = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Block.ogg")
    Sounds.Enemies = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Wasp.ogg")
    Sounds.Ping = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Ping.ogg")
    Sounds.Timeout = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Timeout.ogg")
    Sounds.Step = rl.LoadSound(PATH_TO_DATA + "SOUNDS/Step.ogg")
end

sub UpdateMusic()
    if(MusicPlaying)
        rl.UpdateMusicStream(Music.Tracks[Music.CurrentTrack])        
        if(!rl.IsMusicStreamPlaying(Music.Tracks[Music.CurrentTrack]))
            Music.CurrentTrack++
            if(Music.CurrentTrack > Music.MaxTracks) then Music.CurrentTrack = 1
            rl.PlayMusicStream(Music.Tracks[Music.CurrentTrack])
            rl.SetMusicVolume(Music.Tracks[Music.CurrentTrack], Settings.MusicVolume / 10 * 0.25)
        endif
    endif
end

sub LoadMusic()
    Music.Tracks << rl.LoadMusicStream(PATH_TO_DATA + "SOUNDS/bip-bop.ogg")
    Music.Tracks << rl.LoadMusicStream(PATH_TO_DATA + "SOUNDS/effervesce.ogg")
    Music.Tracks << rl.LoadMusicStream(PATH_TO_DATA + "SOUNDS/running.ogg")
    Music.CurrentTrack = 1
    Music.MaxTracks = len(Music.Tracks)
    if(Settings.MusicVolume == 0) then MusicPlaying = false     
end

sub UnloadTextures()
    local ii

    for ii in LettersBug
        rl.UnloadTexture(ii)
    next    
    for ii in LettersEscape
        rl.UnloadTexture(ii)
    next    
    
    rl.UnloadTexture(Bug)
    rl.UnloadTexture(MenuBG)

    UnloadTiles()
end

sub UnloadTiles()
    local ii
    
    for ii in Tiles
        rl.UnloadTexture(ii.Texture)
    next
end

sub UnloadSounds()
    local ii

    for ii in Sounds
        rl.UnloadSound(Sounds[ii])
    next
end

sub UnloadMusic()
    local ii
    
    for ii in Music.Tracks
        rl.UnloadMusicStream(ii)
    next
end
