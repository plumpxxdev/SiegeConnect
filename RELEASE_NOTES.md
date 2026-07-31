# SiegeConnect v0.1.7

Обновление для Windows и Android с фирменным deep link импортом подписок и DNS-фиксом для TUN.

## Что добавлено

- Deep link импорт подписок: `siegeconnect://add/{{SUBSCRIPTION_LINK}}`.
- Android открывает SiegeConnect по ссылке и автоматически добавляет подписку.
- Windows setup регистрирует `siegeconnect://` при установке.
- Windows portable/app при запуске сам проверяет регистрацию `siegeconnect://` без админки.
- Если SiegeConnect уже открыт в трее, ссылка передается в существующее окно, а второй процесс не запускается.

## Что исправлено

- Убрана регистрация чужой схемы из прошлой сборки; новый билд использует только `siegeconnect://`.
- Старый чужой протокол удаляется из Windows-регистрации, если он был создан SiegeConnect прошлой сборкой.
- Добавлен внутренний DNS-блок Mihomo для TUN, чтобы клиент меньше зависел от ручных DNS-настроек Windows вроде `1.1.1.1`.
- В TUN используется DNS hijack + `fake-ip`, чтобы DNS-запросы не утекали мимо туннеля.
- Обновлены тесты разбора deep link и генерации runtime YAML.

## Как делать кнопку на сайте

```html
<a href="siegeconnect://add/https%3A%2F%2Fexample.com%2Fsub%3Ftoken%3Dabc">
  Добавить в SiegeConnect
</a>
```

Можно использовать и обычную ссылку внутри:

```text
siegeconnect://add/https://example.com/sub?token=abc
```
