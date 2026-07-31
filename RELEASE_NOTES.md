# SiegeConnect v0.1.7

Обновление для Windows и Android с deep link импортом подписок и DNS-фиксом для TUN.

## Что добавлено

- Deep link импорт подписок: `happ://add/{{SUBSCRIPTION_LINK}}`.
- Свой брендовый deep link: `siegeconnect://add/{{SUBSCRIPTION_LINK}}`.
- Android открывает приложение по ссылке и автоматически добавляет подписку.
- Windows setup регистрирует deep link при установке.
- Windows portable/app при запуске сам проверяет регистрацию deep link без админки.
- Если SiegeConnect уже открыт в трее, ссылка передается в существующее окно, а второй процесс не запускается.

## Что исправлено

- Добавлен внутренний DNS-блок Mihomo для TUN, чтобы клиент меньше зависел от ручных DNS-настроек Windows вроде `1.1.1.1`.
- В TUN используется DNS hijack + `fake-ip`, чтобы DNS-запросы не утекали мимо туннеля.
- Обновлены тесты разбора deep link и генерации runtime YAML.

## Как делать кнопку на сайте

```html
<a href="happ://add/https%3A%2F%2Fexample.com%2Fsub%3Ftoken%3Dabc">
  Добавить в SiegeConnect
</a>
```

Можно использовать и небрендовый формат с обычной ссылкой внутри:

```text
happ://add/https://example.com/sub?token=abc
```
