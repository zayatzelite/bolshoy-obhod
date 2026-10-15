# Большой обход — контрольный список выпуска

Это список проверок и ограничений, **не сертификат готовности и не журнал фиктивных PASS**. Статусы задач команды означают завершение правок, но не заменяют GPU-проверку итоговой сборки. База на момент подготовки: Godot 4.7.2, GL Compatibility, viewport 1280×720.

## Что изменено в этом проходе

- Главное меню: initial/return focus выбирает доступную кнопку; собственный shader учитывает disabled; модалки имеют коричневые ink-цвета.
- Общие кнопки: disabled shader использует матовую песочную поверхность; hover/selected сохранены; тест контраста проверяет реальный interior gradient.
- Загрузка: статус помещён на непрозрачную песочную плашку; добавлены guards ошибок ресурсов/сцены и очистка warmed metadata. Тайминг и первый render требуют отдельной GPU-проверки.
- Видоискатель: neutral charcoal/sand, защищённая подпись объекта вместо прежней зелёно-мятной разметки.
- Карточки растений: реальные поля текущего каталога видимы, источник HTTP(S) открывается ссылкой, бумажная рамка; явный отказ от использования иллюстрации как определителя.
- Фотопросмотр: адаптивные границы для 1280×720 и 960×540, читаемый footer, zoom/pan/reset/close.
- FPS-хват: отдельные continuous-перчатки bottle/can/cup; боковая ориентация .85rad, кисть (.34,-.43,-.60), разные позиции предметов. Пальцы и большой палец деформированы по реальным поверхностям. 15 репрезентативных точек проходят signed-depth и nearest-triangle допуск5мм. Это не полная проверка поверхности/анатомии. GPU крупные кадры сохранены; силуэт всё ещё стилизован, не фотореалистичный референс.
- Персонаж: refined asset с привязанными к15костям карманами, молнией, погонами, усилениями; Idle/Walk/Run PASS. 77 shadow-only proxies возвращают upperbody shadow под FPSmask; CPU полная проекция2690px без потерь, GPU силуэт головы/корпуса подтверждён.
- Прогрев загрузки обновлён на refined и4новых grip assets. GPU transition70frames/31staged/max.150s, без ObjectDBwarning в этом прогоне; не cold-cache гарантия.

## Подтверждённые проверки этого исполнителя

Проведены отдельные headless-запуски без ошибок итогового stderr: `ui_contrast_test.gd`, `button_states_test.gd`, `new_game_menu_test.gd`, `plant_card_visual_test.gd`. Это подтверждает соответствующие assertions на момент запусков, **не проверяет GPU-шейдеры визуально и не доказывает финальный integrated release**.

При отдельном headless запуске `plant_card_test.gd` был assertion строки 23 (mouse mode после закрытия); первоначальный причинный вывод отозван. Lead повторил актуальный тест на GPU: PASS с правильным resume callback, без stderr. Не считать PASS лишь потому, что Godot вернул exit code 0.

## Интеграция Lead — 15 октября, утренний проход

Godot 4.7.2 / OpenGL Compatibility / RTX3060 Laptop. Последовательный GPU-прогон: smoke, playable_plants, player_body, map, results_fullscreen, camera_fullscreen, ui_regression — все PASS без stderr. Дополнительно photo (после ожидания нового кадра перед снимком), photo_lightbox_layout, item_grip и loading_transition — PASS; в layout fixture остаётся предупреждение Image.load res:// (не production user://). Загрузка 66 кадров, 31 staged, максимум .147s, без ObjectDB warnings. Эти цифры относятся к конкретному прогону, не гарантируют cold-cache время. Схематичные пальцы/иллюстрации и качество ландшафта ещё не окончательные.

## Визуальный просмотр Lead после подключения новых хватов

Просмотрены loading_art_preview (новый1920берег корректно PNG), patrol_results_preview (после завершения fade, непрозрачный песочный фон/тёмный текст), journal_species_preview (4колонки не пересекают spine), patrol_map_preview (схема/легенда/кнопка читаемы), plant_card_visual_preview (стилизованность/источник/охрана видны). Последние2кадра не переснимались в этом проходе: визуальная оценка существующих артефактов, не ложное утверждение fresh capture. results_test обновлён: поиск Labels/Button по типу вместо childindices, захват только при modulate.a>=.999. GPU PASS. UIregression/journal/loadingart/mapmarkers PASS. Two-delivery8items/200XP PASS с подготовленными позициями, не ручное прохождение. Все15representative grip contacts≤5мм после taper; это не доказательство полного naturalwrap.

## Обязательный gate перед выпуском

- [ ] Указать точную сборку/ревизию и окружение: версия Godot, renderer, разрешение, GPU.
- [ ] Сохранить stdout **и stderr** каждого теста; отсутствие `SCRIPT ERROR`, `Assertion failed`, `ERROR`, необъяснённых leaks. Проверить ожидаемый PASS-маркер и завершение, а не только exit code.
- [ ] Не гонять несколько GPU-тестов одновременно: они меняют window mode, focus, cursor и пишут одинаковые preview-файлы.
- [ ] Открыть игру обычным способом, проверить меню → загрузка → первый управляемый кадр; заметную задержку main-thread не скрывать словом «асинхронная».
- [ ] Проверить Tab/Enter/ESC при disabled «Продолжить», возврат из настроек и модалок.
- [ ] Посмотреть свежие снимки HUD, карты, журнала, карточки, камеры, фотопросмотра и итогов: текст не выходит за рамки, readable contrast, нет случайных зелёных панелей с тёмной ink.
- [ ] Проверить три удерживаемых предмета: пальцы/ладонь касаются предмета, нет большого зазора или явного провала геометрии; world shadow сохраняется, first-person hand shadow не загрязняет сцену.
- [ ] В изолированном user-data проверить фото/метки/навыки и повторный запуск; не сбрасывать живые пользовательские сохранения ради теста.
- [ ] Выпускать только фактически существующий пакет/сборку. Наличие исходников не означает наличие экспортированного релиза.

## Порядок тестов для Lead

Все перечисленные тестовые скрипты обнаружены в `game/scripts`. Ниже **предложение очереди**, не утверждение, что она уже пройдена. Из workspace запускать один процесс на тест:

```powershell
& $godot --headless --path game --script res://scripts/ui_contrast_test.gd --quit-after 120
# Для GPU capture-тестов убрать --headless; окно открывает только Lead.
& $godot --path game --script res://scripts/photo_test.gd --quit-after 1800
```

### A. Быстрые headless gates (до GPU)

1. `ui_contrast_test.gd` — фактическая shader-палитра/disabled ink.
2. `button_states_test.gd` — selected и initial/dynamic disabled.
3. `new_game_menu_test.gd` — фокус, warm ink, reset confirmation без reset save.
4. `photo_lightbox_layout_test.gd` — 1280/960, pan, footer, close.
5. `plant_card_visual_test.gd` — поля всех 21 записей, source safety, длинный текст; headless ветка не захватывает screenshot.
6. `grip_geometry_test.gd` — замер контакта на треугольниках; не равно визуальному одобрению.
7. `loading_transition_test.gd` — guards, монотонность progress, staged playable transition; отдельный GPU повтор всё равно нужен.

### B. Ordered GPU smoke (приоритет при коротком дедлайне)

1. `loading_transition_test.gd` — итоговая цепочка загрузки и longest-frame метрика. Дополнительно Lead вручную проверяет, что loading действительно успел отрисоваться.
2. `camera_fullscreen_test.gd` — HUD level + neutral viewfinder, вход/выход камеры, сохранение видимости сцены.
3. `photo_test.gd` — полный photo/camera/journal/lightbox цикл; создаёт фото и test manifest, потому нужен isolated user-data. Сохранённый PNG не содержит рамку видоискателя.
4. `journal_visual_test.gd` — задачи/21 species captions; затем `plant_card_visual_test.gd` GPU для свежей карточки.
5. `map_test.gd` — схема, координаты, метки/повторное открытие, HUD hide.
6. `item_grip_test.gd` — три свежих capture удерживаемых предметов; Lead просматривает их, не полагается лишь на rig assertions.
7. `ui_regression_test.gd` — bounded skills/pause/settings/map/inventory/journal, ESC и скрытые пустые подсказки.
8. `hud_bounds_test.gd` — многострочные hint/notice.
9. `results_fullscreen_test.gd` — итоговые показатели/return; тест жёстко ожидает physical 1920×1080, поэтому запускать на соответствующем экране либо отметить несовместимость fixture, не выдавать за баг игры.
10. Разобрать `plant_card_test.gd:23` отдельно и записать доказанную причину/результат.

`loading_art_test.gd` не включён в обязательную очередь: preview fixture отключает processing и вручную потребляет requests; перед запуском Lead должен проверить совместимость с актуальными staged loader requests. Не применять его старый PASS как доказательство production transition.

## Запуск и управление

Открыть `game/project.godot` в Godot 4.7.x (GL Compatibility) и запускать проект с main scene bootstrap; либо:

```powershell
& $godot --path game
```

WASD — ходьба; Shift — бег; Пробел — прыжок; E — действие; I — рюкзак; R — убрать/достать; 1–3 — предмет из рюкзака; G — положить; M — карта; Tab — навыки/журнал; Esc — пауза/назад. C — фотоаппарат; ПКМ — видоискатель; ЛКМ — снимок. В фотопросмотре: колесо — масштаб, перетаскивание — обзор, двойной щелчок — сброс, Esc — назад.

## Честные ограничения

- **21 текущая запись, не 22.** Не дорисовывать недостающий вид ради числа; `verified_demo_21` — демонстрационный каталог.
- Иллюстрации/модели стилизованы. Точки растений и карта условны, не реальные координаты и не туристический навигатор.
- Видимый текст отражает имеющиеся catalog fields; их показ **не доказывает научную точность**. Индивидуальные категории охраны/сроки цветения не следует обещать, если их нет в записи.
- Отдельные headless PASS не доказывают качество изображения, FPS, отсутствие clipping во всех разрешениях или отсутствие ошибок под реальным renderer.
- Длинный загрузочный compile/startup stall и неизвестные stderr должны оставаться явными ограничениями до измеренной проверки, а не исчезать из отчёта.
