# Cash Machine Service via REST API.

## Starting server:

```
rackup config.ru
```

## Methods:

### POST /cash_machine/initialize

Attributes:

* cash_to_load 

Example:

```
{"cash_to_load": {"50":3,"25":2,"10":1}}
```

Response:
```
{"50":3,"25":2,"10":1}
```

Description:

Initialize cash machine. Should be called before calling /cash_machine/receive_cash

### POST /cash_machine/receive_cash

Attributes:

* requested_amount

Example:
```
{"requested_amount": 200}
```

Response:
```
{"50":3,"25":2}
```

Description:

Retrieve cash from the cashing machine. It will decrease amount for money in the cashing machine.
