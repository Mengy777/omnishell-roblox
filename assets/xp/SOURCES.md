# Источники оформления Windows XP

Ресурсы используются для локального интерфейса XP в Roblox Studio. Это не исходники или исполняемые файлы Windows.

- Обои: [bartekl1/windows-ui-assets, Windows XP Desktop](https://github.com/bartekl1/windows-ui-assets/tree/main/Wallpapers/Windows%20XP/Desktop). Bliss.bmp — оригинал из коллекции, Bliss.png — его преобразование в PNG без изменения изображения. Autumn.jpg и Windows XP.jpg — из той же коллекции. Права на оригинальные материалы сохраняются у их правообладателей.
- Значки: [ShizukuIchi/winXP](https://github.com/ShizukuIchi/winXP/tree/856bb554b3667f62078010b4cee10cc2645761e1/src/assets/windowsIcons), commit `856bb554b3667f62078010b4cee10cc2645761e1`. Лицензия проекта сохранена в `REFERENCE-LICENSE.txt`; она не меняет права на исходные материалы Microsoft.
- Референс геометрии, цветов Luna и элементов окон: [XP.css](https://github.com/botoxparty/XP.css), [документация компонентов](https://botoxparty.github.io/XP.css/). Код CSS не используется как движок интерфейса.
- Tahoma и Trebuchet MS копируются только из установленной Windows владельца в локальную папку ресурсов при сборке. Бинарные файлы шрифтов не публикуются в репозитории.
- Локальные ресурсы подключаются через [официально описанную схему rbxasset](https://create.roblox.com/docs/projects/assets#rbxasset). `sync-xp-assets.ps1` создаёт только собственную подпапку `content/omnishell/xp`, не заменяя ресурсы Roblox.

Дополнительно:

- Полный набор обоев Desktop и 35 WAV-файлов из [bartekl1/windows-ui-assets](https://github.com/bartekl1/windows-ui-assets), разделы `Wallpapers/Windows XP/Desktop` и `Sounds/Windows XP`.
- Растровые части Luna Blue/Olive/Silver, 25 изображений пользователей, логотип и монитор предпросмотра: [aduncandev/web-xp](https://github.com/aduncandev/web-xp), проверенный commit `bc9528db08c3714e6dfd52be43e1dcb3fe4a216a`, папки `src/assets/xp/luna`, `src/assets/userIcons`, `src/assets/windowsIcons` и `src/assets/xp`. Лицензия проекта сохранена в `WEB-XP-LICENSE.txt`. BMP-профили преобразованы в PNG без изменения изображения; для серебристой схемы `Framecaption-*` сохранены под унифицированным именем `FrameCaption-*`.
- Корзина, учетные записи, переключение пользователя и значок экрана: [holylance98/WinXpIcons](https://github.com/holylance98/WinXpIcons).
- Для сравнения геометрии просмотрен референсный снимок `refkit/vm/luna-dp-desktop.png` из web-xp. Полный визуальный прогон текущей сборки не выполнен.
- Lucida Console также копируется только из локальной Windows; TTF в Git не добавляются.
- `start.wav` в коллекции использует ADPCM. Для совместимости рабочая копия декодирована FFmpeg в PCM WAV без изменения содержания; исходный файл сохранён в `sounds-original/start.wav`.
- Пользователь потребовал оставить только стандартный курсор Roblox. Ранее добавленные CUR/PNG курсора XP и конвертер удалены; дополнительный указатель не отображается.

После обновления Roblox Studio нужно повторить `scripts/sync-xp-assets.ps1` или обычную сборку, чтобы добавить ресурсы в новую папку версии. Для переноса сборки на другой компьютер нужны папка `assets` и повторная синхронизация ресурсов.
