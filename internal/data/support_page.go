package data

import (
	"database/sql"
	"errors"
)

type SupportPageData struct {
	SupportInfo *SupportInfo      `json:"support_info"`
	Performance *PerformanceStats `json:"performance"`
}

type SupportInfo struct {
	SupportID int64  `json:"support_id"`
	Fname     string `json:"first_name"`
	Lname     string `json:"last_name"`
	Image_url string `json:"image_url"`
}

type PerformanceStats struct {
	AvgTimeToSecondFraudBadge float64 `json:"avg_time_to_second_fraud_badge"`
	PercentageBanned          float64 `json:"percentage_banned"`
	PercentageLowSellingRate  float64 `json:"percentage_low_selling_rate"`
	ActionsLastWeekCount      int     `json:"actions_last_week_count"`
	MaxBenefitFromDiscounts   float64 `json:"max_benefit_from_discounts"`
}

type SupportPageModel struct {
	DB *sql.DB
}

func (m SupportPageModel) GetSupportPageData(supportID int64) (*SupportPageData, error) {
	supportInfo, err := m.GetSupportInfo(supportID)
	if err != nil {
		return nil, err
	}

	avgTime, err := m.GetAvgTimeToSecondFraudBadge(supportID)
	if err != nil {
		return nil, err
	}

	percentageBanned, err := m.GetPercentageBanned(supportID)
	if err != nil {
		return nil, err
	}

	percentageLowSelling, err := m.GetPercentageLowSellingRate(supportID)
	if err != nil {
		return nil, err
	}

	actionsCount, err := m.GetActionsLastWeekCount(supportID)
	if err != nil {
		return nil, err
	}

	maxBenefit, err := m.GetMaxBenefitFromDiscounts(supportID)
	if err != nil {
		return nil, err
	}

	performance := &PerformanceStats{
		AvgTimeToSecondFraudBadge: avgTime,
		PercentageBanned:          percentageBanned,
		PercentageLowSellingRate:  percentageLowSelling,
		ActionsLastWeekCount:      actionsCount,
		MaxBenefitFromDiscounts:   maxBenefit,
	}

	return &SupportPageData{
		SupportInfo: supportInfo,
		Performance: performance,
	}, nil
}

func (m SupportPageModel) GetSupportInfo(supportID int64) (*SupportInfo, error) {
	query := ``
	// TODO: Write query

	var support SupportInfo
	err := m.DB.QueryRow(query, supportID).Scan(
		&support.SupportID,
		&support.Fname,
		&support.Lname,
		&support.Image_url,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &support, nil
}

func (m SupportPageModel) GetAvgTimeToSecondFraudBadge(supportID int64) (float64, error) {
	query := ``
	// TODO: Write query

	var avgTime float64
	err := m.DB.QueryRow(query, supportID).Scan(&avgTime)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return 0, nil
		default:
			return 0, err
		}
	}
	return avgTime, nil
}

func (m SupportPageModel) GetPercentageBanned(supportID int64) (float64, error) {
	query := ``
	// TODO: Write query

	var percentage float64
	err := m.DB.QueryRow(query, supportID).Scan(&percentage)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return 0, nil
		default:
			return 0, err
		}
	}
	return percentage, nil
}

func (m SupportPageModel) GetPercentageLowSellingRate(supportID int64) (float64, error) {
	query := ``
	// TODO: Write query

	var percentage float64
	err := m.DB.QueryRow(query, supportID).Scan(&percentage)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return 0, nil
		default:
			return 0, err
		}
	}
	return percentage, nil
}

func (m SupportPageModel) GetActionsLastWeekCount(supportID int64) (int, error) {
	query := ``
	// TODO: Write query

	var count int
	err := m.DB.QueryRow(query, supportID).Scan(&count)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return 0, nil
		default:
			return 0, err
		}
	}
	return count, nil
}

func (m SupportPageModel) GetMaxBenefitFromDiscounts(supportID int64) (float64, error) {
	query := ``
	// TODO: Write query

	var maxBenefit float64
	err := m.DB.QueryRow(query, supportID).Scan(&maxBenefit)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return 0, nil
		default:
			return 0, err
		}
	}
	return maxBenefit, nil
}
